start powershell.exe -ArgumentList "-File $PSScriptRoot\vwsms.ps1" -Verb runAs
start powershell.exe -ArgumentList "-File $PSScriptRoot\runte.ps1" -Verb runAs

start devenv.exe "C:\work\IO\IntelliFlo.IO.ALL.sln" -Verb runAs