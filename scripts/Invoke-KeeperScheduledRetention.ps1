#Requires -Version 5.1
<#
.SYNOPSIS
    Scheduled entry point for Invoke-KeeperCacheRetention: one run, one log file, one exit code.

.DESCRIPTION
    Loads Write-Log and the Groundskeeper module, points the log at
    logs/keeper.cache.retention_YYYYMMDD.log, runs Invoke-KeeperCacheRetention without
    prompting, and exits with the command's ExitCode (0, the mapped code of the worst failure,
    or 112 when a free-space threshold is breached). Without -Remove it only reports.
    The systemd units in deploy/systemd run it with -Remove.

.PARAMETER Remove
    Delete the stale cache versions. Without it the run is a preview.

.PARAMETER ConfigPath
    Rule file to apply. Defaults to Config/CacheRetentionRules.psd1 in this folder.

.EXAMPLE
    pwsh -NoProfile -File ./scripts/Invoke-KeeperScheduledRetention.ps1

    Previews what a removal run would do and exits 0 when nothing is wrong.

.EXAMPLE
    pwsh -NoProfile -File ./scripts/Invoke-KeeperScheduledRetention.ps1 -Remove

    Removes the stale cache versions and exits with the run's code.
#>
[CmdletBinding()]
param(
    [switch]$Remove,

    [string]$ConfigPath
)
$ModuleRoot = Split-Path -Parent $PSScriptRoot

. (Join-Path (Join-Path $ModuleRoot 'Private') 'Write-Log.ps1')
. (Join-Path (Join-Path $ModuleRoot 'Private') 'Get-WindowsErrorCode.ps1')

$script:ExitCode = 0
$retentionLog = Join-Path (Join-Path $ModuleRoot 'logs') "keeper.cache.retention_$(Get-Date -Format 'yyyyMMdd').log"
$env:KEEPER_LOG_PATH = $retentionLog
Initialize-Log -LogFilePath $retentionLog -ScriptName 'Invoke-KeeperScheduledRetention'

$moduleLoaded = $false
try {
    Write-Log "Attempting ModuleImport on '$(Join-Path $ModuleRoot 'Groundskeeper.psd1')'" -Severity Info
    Import-Module (Join-Path $ModuleRoot 'Groundskeeper.psd1') -Force -ErrorAction Stop
    $moduleLoaded = $true
    Write-Log 'ModuleImport succeeded for Groundskeeper' -Severity Success
}
catch {
    Write-Log "ModuleImport failed for Groundskeeper: $($_.Exception.GetType().Name) at line $($_.InvocationInfo.ScriptLineNumber): $($_.Exception.Message)" -Severity Error
    $code = Get-WindowsErrorCode -Exception $_
    if ($code -gt $script:ExitCode) { $script:ExitCode = $code }
}

if ($moduleLoaded) {
    $retentionParameters = @{ Confirm = $false }
    if ($Remove) { $retentionParameters.Remove = $true }
    if ($ConfigPath) { $retentionParameters.ConfigPath = $ConfigPath }
    $result = Invoke-KeeperCacheRetention @retentionParameters
    if ([int]$result.ExitCode -gt $script:ExitCode) { $script:ExitCode = [int]$result.ExitCode }
}

Write-LogFinal -Message "Invoke-KeeperScheduledRetention finished. Exit code: $script:ExitCode" -Severity Info
exit $script:ExitCode
