#using module E:\GitProjects\IdealTool\Modules\Utils\StringHelper.psm1
using module .\Utils\StringHelper.psm1

class ComHandlers
{
   static [string] URunHandle([string] $scriptsFolder, [string]$params)
    {
        if([string]::IsNullOrWhiteSpace($params))
        { return "You must specify script name for this command" }
        
        $scriptName = $params.Trim()
        
        if(-not [StringHelper]::StringIsMatchedToRegExp($scriptName, '^([a-zA-Z0-9\-_]+)$'))
        { return "Script name allowed characters: english alphabet, '-' and '_'" }
        $scriptFullPath = "$scriptsFolder\$scriptName.ps1"
        
        if(-not (Test-Path -Path $scriptFullPath))
        { return "Unmanaged Script '$scriptName' doesn't exists in folder: $scriptsFolder" }

        start powershell.exe -File $scriptFullPath

        return "Script: $scriptName has successfully started"
    }
}