using module .\_BaseTool.psm1
using module .\PowerShellTool.psm1
using module ..\..\Logger.psm1
using module ..\Helpers\CommonHelper.psm1

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

    RunProject([string] $projectPath, [bool] $isReleaseMode)
    {   
        if(-not [DotNetTool]::IsAvailable)
        { 
            $this.Logger.LogInfo("DotNetTool is unavailable due unexisting 'dotnet' command. Try install last .net framework")
            return 
        }
        [PowerShellTool] $psTool = [PowerShellTool]::new($this.Logger)
        [string] $configuration = [CH]::Ternary($isReleaseMode, "Release", "Debug")
        $commandString = "dotnet run --project $projectPath --configuration $configuration"
        $psTool.Execute($commandString)
    }

    Build([string] $path, [bool] $isReleaseMode)
    {
        if(-not [DotNetTool]::IsAvailable)
        { 
            $this.Logger.LogInfo("DotNetTool is unavailable due unexisting 'dotnet' command. Try install last .net framework")
            return 
        }
        [string] $configuration = [CH]::Ternary($isReleaseMode, "Release", "Debug")
        $commandString = "dotnet build $path --configuration $configuration"

        $buildlog = Invoke-Expression $commandString
        $this.ShowLog($buildLog)
    }

    
    ShowLog($buildLog)
    {
        foreach ($line in $buildLog) {
            $this.Logger.LogSimpleText($line)
        }
    }

}