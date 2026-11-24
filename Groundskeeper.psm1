#Requires -Version 5.1
<#
    .SYNOPSIS
        Groundskeeper module loader: rule-driven cleanup of agent plugin caches.

    .NOTES
    =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
   
    =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
    -  Author:        Curtis Leggett                                  -
    =  Copyright:     2026 Divergent Cortex                           =
    -  Organization:  Divergent Cortex                                -
    =  Version:       See docs/CHANGELOG.md                           =
    =-=-                       =-=-=-=-=-=-=-=                     -=-=
    -  it is not water they seek, but the truth beneath the trees     -
    =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

    .DESCRIPTION
        Loads the Groundskeeper module. Sets PS 5.1 platform-compat variables, picks a log path, dot-sources every Private and Public file, reads the version from the newest CHANGELOG slot, starts the Write-Log logger and exports the public command.
#>


# 5.1 doesn't know what linux is, bless it, so we hand it $IsWindows/$IsLinux/$IsMacOS
# on pwsh 6+ those are read-only automatics, hence the version gate and Set-Variable
if ($PSVersionTable.PSVersion.Major -lt 6) {
    Set-Variable -Name 'IsWindows' -Value $true  -Scope Script
    Set-Variable -Name 'IsLinux'   -Value $false -Scope Script
    Set-Variable -Name 'IsMacOS'   -Value $false -Scope Script
}

$script:KeeperRoot = $PSScriptRoot
$script:KeeperLogPath = if ($env:KEEPER_LOG_PATH) { $env:KEEPER_LOG_PATH } else { Join-Path (Join-Path $PSScriptRoot "logs") "keeper.module_$(Get-Date -Format yyyyMMdd).log" }

# version is the latest changelog slot, read at load so nothing hardcodes it
$script:KeeperVersion = 'unknown'
$changelogPath = Join-Path (Join-Path $PSScriptRoot 'docs') 'CHANGELOG.md'
if (Test-Path -LiteralPath $changelogPath) {
    $head = Get-Content -LiteralPath $changelogPath |
        Where-Object { $_ -match '^##\s*\[[^\]]+\]' } | Select-Object -First 1
    if ($head -match '^##\s*\[(?<ver>[^\]]+)\]') {
        $script:KeeperVersion = $Matches['ver'] 
    }
}


$Public = @(Get-ChildItem -Path (Join-Path (Join-Path $PSScriptRoot 'Public') '*.ps1') -ErrorAction SilentlyContinue)
$Private = @(Get-ChildItem -Path (Join-Path (Join-Path $PSScriptRoot 'Private') '*.ps1') -ErrorAction SilentlyContinue)

foreach ($file in @($Private + $Public)) {
    try {
        . $file.FullName 
    }
    catch {
        Write-Warning "Failed to import $($file.FullName): $($_.Exception.GetType().Name) at line $($_.InvocationInfo.ScriptLineNumber): $($_.Exception.Message)"
    }
}
Initialize-Log -LogFilePath $script:KeeperLogPath -ScriptName "Groundskeeper" -Version $script:KeeperVersion

Export-ModuleMember -Function "Invoke-KeeperCacheRetention"
