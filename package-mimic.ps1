param(
    [string]$Version = "1.0.2"
)

& "$PSScriptRoot\package.ps1" -Project mimic -Version $Version
