$processes = Get-Process -Name powershell_ise
$processes | ForEach-Object {Stop-Process  $_.Id}
Start-Sleep -Seconds 0.2
& C:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell_ise.exe $PSScriptRoot\Global.psm1
& C:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell_ise.exe $PSScriptRoot\Main.ps1