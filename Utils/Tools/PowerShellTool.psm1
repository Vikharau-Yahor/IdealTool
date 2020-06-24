using module .\_BaseTool.psm1
using module ..\..\Logger.psm1
using module ..\..\Global.psm1

class PowerShellTool : BaseTool
{   
    static [string] $DefaultPowerShellPath = "Powershell.exe"
    static [bool] $IsAvailable = $false
    static [string] $Powershell
    
    PowerShellTool([Logger] $logger) : base($logger)
    {
        if([PowerShellTool]::IsAvailable -eq $false)
        {
            if(-not [string]::IsNullOrEmpty([UserSettings]::PowershellPath) -and (Test-Path [UserSettings]::PowershellPath)) {
                [PowerShellTool]::Powershell = [UserSettings]::PowershellPath
                [PowerShellTool]::IsAvailable = $true
            }
            else {
                [PowerShellTool]::Powershell = [PowerShellTool]::DefaultPowerShellPath 
                try
                {
                    [System.Diagnostics.Process]$process = Start-Process -FilePath ([PowerShellTool]::Powershell) -PassThru
                    Stop-Process -Id $process.Id
                    [PowerShellTool]::IsAvailable = $true
                }
                catch      
                {
                    $this.Logger.LogError($_.ToString())
                    [PowerShellTool]::IsAvailable = $false
                }
            }
            
        }
    }

    #execute commands in new powershell window
    Execute([string] $commandsString)
    {   
        if(-not [PowerShellTool]::IsAvailable)
        { 
            $this.Logger.LogInfo("PowerShellTool is unavailable due unexisting 'powershell.exe'. Try install specify full path to powershell.exe in UserSettings (Global.psm1)")
            return 
        }
        if($commandsString -eq $null)
        { 
            $this.Logger.LogInfo("PowerShellTool.Execute: input commandsString cannot be null")
            return 
        }
        $powerShellPath = [PowerShellTool]::Powershell
        $bytes = [System.Text.Encoding]::Unicode.GetBytes($commandsString)
        $encodedCommand = [Convert]::ToBase64String($bytes)
        
        Start-Process $powerShellPath -ArgumentList "-EncodedCommand $encodedCommand"
        
    }

}