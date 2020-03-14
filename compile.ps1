$curPath = Get-Location


Set-Location (Join-Path $PSScriptRoot scripts)

. ./Update-Index.ps1

Set-Location $curPath