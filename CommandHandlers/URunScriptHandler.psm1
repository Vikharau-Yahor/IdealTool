using module .\_CommandHandlerBase.psm1
using module ..\Global.psm1
using module ..\Utils\Helpers\StringHelper.psm1
using module ..\Storages\_StorageProvider.psm1
using module ..\Logger.psm1

class URunScriptHandler : CommandHandlerBase
{

    URunScriptHandler ([StorageProvider]$storageProvider, [Logger] $logger, [string]$commandParams) : base($storageProvider, $logger, $commandParams)
    {  }

    #overridden
    [void] Handle()
    { 
        $scriptsFolder = "$([Global]::RootPath)\$([Global]::UnManagedScriptsPath)"
        $params = $this.CommandParams

        if([string]::IsNullOrWhiteSpace($params))
        { 
            $this.Logger.LogInfo("You must specify script name for this command")
            return
        }
        
        $scriptName = $params.Trim()
        
        if(-not [StringHelper]::StringIsMatchedToRegExp($scriptName, '^([a-zA-Z0-9\-_]+)$'))
        { 
            $this.Logger.LogInfo("Script name allowed characters: english alphabet, '-' and '_'") 
            return
        }
        
        $scriptFullPath = "$scriptsFolder\$scriptName.ps1"
        
        if(-not (Test-Path -Path $scriptFullPath))
        { 
            $this.Logger.LogInfo("Unmanaged Script '$scriptName.ps1' doesn't exists in folder: $scriptsFolder") 
            return
        }

        Start-Process powershell.exe -ArgumentList "-File $scriptFullPath" -Verb runAs

        $this.Logger.LogInfo("Script: '$scriptName.ps1' has successfully started")
    }
}