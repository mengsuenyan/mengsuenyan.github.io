$curPath = Get-Location


Set-Location (Join-Path $PSScriptRoot scripts)

. ./Update-Index.ps1

Set-Location $curPath

./index.html

if (Test-Path ..\push.ps1) {
    ../push.ps1
}