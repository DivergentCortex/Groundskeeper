# Groundskeeper

Prunes stale versions from AI agent plugin caches.

Claude Code and Codex keep every plugin version they ever installed in a cache folder, and over a few weeks those folders pile up. Groundskeeper removes the old versions by rule and leaves alone anything that is still in use.

## What it keeps

A version is kept when any of these is true:

- it is the installed version named in the plugin manifest
- a running process holds it as a working directory, executable, open file, mapped file, command line argument or environment value
- a running agent seat started on it, or on the version before it
- it is one of the newest N versions by dotted version number (2 in the shipped rules)
- it is a symlink, or sits under a symlinked folder
- a file in it was written inside the quiet window (60 minutes in the shipped rules)
- its name is not a dotted version number

If the installed manifest or the process scan cannot be read, nothing is removed for that run. A folder whose size cannot be measured is kept.

## Install

    git clone https://github.com/DivergentCortex/Groundskeeper.git
    Import-Module ./Groundskeeper/Groundskeeper.psd1

## Use

Preview is the default. Nothing is touched, and the output lists every folder, the decision, its size and the total a removal would free.

    Invoke-KeeperCacheRetention

To remove the folders marked Remove, add -Remove. Deletes go through ShouldProcess, so -WhatIf and -Confirm work, and the process scan is repeated just before each delete.

    Invoke-KeeperCacheRetention -Remove

The result carries an ExitCode: 0 when nothing failed, otherwise the mapped Windows error code of the worst failure, or 112 when free space on a watched filesystem is below its minimum. Free space is only reported, never acted on.

## Rules

Rules live in Config/CacheRetentionRules.psd1. The shipped file lists the plugin names from the author setup, so edit the marketplaces and plugins to match your own cache. Each rule names the cache root to prune, which processes count as agent seats, how many versions to keep and how long a folder must be quiet. The header of the file documents every key.

## Scheduled runs

scripts/Invoke-KeeperScheduledRetention.ps1 is a one-shot entry point that writes its own log and exits with the run code. Example systemd user units and install steps are in deploy/systemd. Nothing in this repository installs or enables them.

## Platforms

Developed and tested on Linux with PowerShell 7. The manifest declares Windows PowerShell 5.1 and PowerShell 7 on Windows, Linux and macOS. On Windows and macOS the process check is reduced: it reads the executable path of each process, and on Windows its command line.

## Tests

    Invoke-Pester -Path ./Tests -Output Detailed

Every test runs against a fixture cache tree under the temp folder.

## Logging

Logging uses Write-Log, a CMTrace-compatible logger by Curtis Leggett, bundled in Private/Write-Log.ps1.

## License

MIT. See LICENSE.
