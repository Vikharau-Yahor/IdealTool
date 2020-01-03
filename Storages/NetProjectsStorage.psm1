using namespace System.Collections.Generic

using module ..\Models\NetModels.psm1
using module ..\Utils\Helpers\XmlHelper.psm1
using module ..\Logger.psm1

class NetProjectsStorage
{
    [string] $ConfigFullPath
    [NSolution[]] $Solutions
    [NProject[]] $PrimaryProjects
    [Logger] $Logger

    NetProjectsStorage([string]$cfgPath, [Logger] $logger)
    {
        $this.ConfigFullPath = $cfgPath
        $this.Logger = $logger
        $this.Reload()
    }

    Reload()
    {
        $this.Solutions = @()

        if(-not (Test-Path -Path $this.ConfigFullPath))
        { return }
               
        try
        {
            [NetSolutionsContainer]$netSolutionsContainer = [XmlHelper]::Deserialize([NetSolutionsContainer], $this.ConfigFullPath)
            
            if( $netSolutionsContainer -eq $null -or $netSolutionsContainer.NetSolutions -eq $null)
            { return }

            $this.Solutions = $netSolutionsContainer.NetSolutions
        }
        catch [System.Exception]
        {
            $this.Logger.LogError("Git repositories deserialization has been failed from file: $($this.ConfigFullPath). Exception:$($_.Exception)")         
        }
    }
}