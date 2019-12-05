start powershell.exe -File "$PSScriptRoot\vwsms.ps1" -noexit -Verb runAs
start powershell.exe -File "$PSScriptRoot\runte.ps1" -Verb runAs

start devenv.exe "c:\work\io\IOAll.sln" -Verb runAs