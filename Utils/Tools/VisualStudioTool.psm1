using module .\_BaseTool.psm1
using module ..\..\Logger.psm1
using module ..\..\Global.psm1

class VisualStudioTool : BaseTool
{   
    static [string] $DefaultDevenvPath = "devenv.exe"
    static [bool] $IsAvailable = $false
    static [string] $DevEnvExe

    VisualStudioTool([Logger] $logger) : base($logger)
    {
         if([VisualStudioTool]::IsAvailable -eq $false)
         {
            if(-not [string]::IsNullOrEmpty([UserSettings]::DevEnvPath) -and (Test-Path ([UserSettings]::DevEnvPath))) {
                [VisualStudioTool]::DevEnvExe = [UserSettings]::DevEnvPath
                [VisualStudioTool]::IsAvailable = $true
            }
            else {
                [VisualStudioTool]::DevEnvExe = [VisualStudioTool]::DefaultDevenvPath 
                try
                {
                    [System.Diagnostics.Process]$process = Start-Process -FilePath ([VisualStudioTool]::DevEnvExe) -PassThru
                    Stop-Process -Id $process.Id
                    [VisualStudioTool]::IsAvailable = $true
                }
                catch
                {
                    [VisualStudioTool]::IsAvailable = $false
                }
            }
         }
    }

    Open([string] $dotNetItemPath)
    {   
        if(-not [VisualStudioTool]::IsAvailable)
        { 
            $this.Logger.LogInfo("VisualStudioTool is unavailable due unexisting 'devenv.exe'. Try install visual studio and specify path to 'devenv.exe' in UserSettings (Global.psm1)")
            return 
        }

        if([string]::IsNullOrEmpty($dotNetItemPath) -or -not (Test-Path $dotNetItemPath))
        { 
            $this.Logger.LogInfo("VisualStudioTool.Open: specified path isn't associated with real file or folder: '$dotNetItemPath'")
            return 
        }

        $args = @($dotNetItemPath)
        Start-Process -FilePath ([VisualStudioTool]::DevEnvExe) -Verb RunAs -ArgumentList $args
    }
}