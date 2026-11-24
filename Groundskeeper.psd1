#Requires -Version 5.1
<#
.SYNOPSIS
    Module manifest for Groundskeeper, a rule-driven cleaner for agent plugin caches.

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
        Declares the exported command surface and module metadata. Loading logic
        lives in Groundskeeper.psm1.
#>

@{
    RootModule        = 'Groundskeeper.psm1'
    ModuleVersion     = '2026.11.23.1'
    GUID              = 'f2088fcb-8e06-4816-83fc-fbc0cc92d5ca'
    Author            = 'Curtis Leggett'
    CompanyName       = 'Divergent Cortex'
    Copyright         = '(c) 2026 Curt Leggett. Licensed under the MIT License.'
    Description       = 'Groundskeeper - prunes stale versions from agent plugin caches by rule and reports low free disk space. Preview by default. Linux, Windows and macOS.'
    PowerShellVersion = '5.1'
    CompatiblePSEditions = @('Desktop', 'Core')
    FunctionsToExport = @(
        'Invoke-KeeperCacheRetention'
    )
    AliasesToExport   = @('*')
    CmdletsToExport   = @()
    VariablesToExport = @()
    PrivateData = @{
        PSData = @{
            Tags = @('cache','retention','cleanup','plugins','claude','codex','powershell','cross-platform')
            ProjectUri = 'https://github.com/DivergentCortex/Groundskeeper'
        }
    }
}
