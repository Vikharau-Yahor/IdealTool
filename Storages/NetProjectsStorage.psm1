using namespace System.Collections.Generic

using module .\ActionItemsStorage.psm1
using module ..\Models\ActionItemType.psm1
using module ..\Models\NetModels.psm1
using module ..\Utils\Helpers\XmlHelper.psm1
using module ..\Logger.psm1

class NetProjectsStorage
{
    [string] $ConfigFullPath
    [NSolution[]] $Solutions
    [NProject[]] $PrimaryProjects
    [Logger] $Logger
    [ActionItemsStorage] $ActionItemsStorage

    NetProjectsStorage([string]$cfgPath, [ActionItemsStorage] $actionItemsStorage, [Logger] $logger)
    {
        $this.ConfigFullPath = $cfgPath
        $this.ActionItemsStorage = $actionItemsStorage
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
            $this.Solutions | ForEach-Object {
                $solution = $_
                $solution.NProjects | ForEach-Object {
                    $_.Solution = $solution
                }
            }
        }
        catch [System.Exception]
        {
            $this.Logger.LogError("Net projects deserialization has been failed from file: $($this.ConfigFullPath). Exception:$($_.Exception)")         
        }
    }

    Add([NSolution[]] $nSolutions)
    {
         if($nSolutions -eq $null -or $nSolutions.Count -eq 0)
         { 
            $this.Logger.LogInfo("NetProjectsStorage saves nothing because input solutions array is empty")
            return 
         }
         $this.Solutions = $nSolutions
         $this.Save()
    }

    Save()
    {
        [NetSolutionsContainer] $nSolutionsContainer = [NetSolutionsContainer]::new()
        $nSolutionsContainer.NetSolutions = $this.Solutions

        [XmlHelper]::Serialize($nSolutionsContainer, $this.ConfigFullPath)
        $this.Logger.LogInfo("New .net solutions have been successfully saved to file: $($this.ConfigFullPath)")

        [List[NProject]] $allNewProjects = @()

        $this.Solutions | ForEach-Object{
            $allNewProjects.AddRange($_.NProjects)
        }

        #save actionItems
        $this.ActionItemsStorage.Add($this.Solutions, [ActionItemType]::NSolution)
        $this.ActionItemsStorage.Add($allNewProjects, [ActionItemType]::NProj)
    }
}