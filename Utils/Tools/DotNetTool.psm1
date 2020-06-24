using module .\_BaseTool.psm1
using module .\PowerShellTool.psm1
using module ..\..\Logger.psm1

class DotNetTool : BaseTool
{   
    static [bool] $IsAvailable = $false

    DotNetTool([Logger] $logger) : base($logger)
    {
        if([DotNetTool]::IsAvailable -eq $false)
        {
            try
            {
                $__ = dotnet
                [DotNetTool]::IsAvailable = $true
            }
            catch
            {
                [DotNetTool]::IsAvailable = $false
            }
        }
    }

    RunProject([string] $projectPath, [string]$configuration)
    {   
        if(-not [DotNetTool]::IsAvailable)
        { 
            $this.Logger.LogInfo("DotNetTool is unavailable due unexisting 'dotnet' command. Try install last .net framework")
            return 
        }
        [PowerShellTool] $psTool = [PowerShellTool]::new($this.Logger)
        $commandString = "dotnet run --project $projectPath --configuration $configuration"
        $psTool.Execute($commandString)
    }

}