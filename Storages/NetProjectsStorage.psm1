using namespace System.Collections.Generic

using module .\_AbstractActionItemsStorage.psm1
using module .\ActionItemsStorage.psm1
using module .\CachedActionItemsStorage.psm1
using module ..\Models\ActionItemType.psm1
using module ..\Models\NetModels.psm1
using module ..\Utils\Helpers\XmlHelper.psm1
using module ..\Utils\Helpers\CommonHelper.psm1
using module ..\Logger.psm1

class NetProjectsStorage : AbstractActionItemsStorage
{
    [NSolution[]] $Solutions
    [NProject[]] $PrimaryProjects
    
    [ActionItemsStorage] $ActionItemsStorage
    [CachedActionItemsStorage] $CachedActionItemsStorage

    NetProjectsStorage([string]$cfgPath, [ActionItemsStorage] $actionItemsStorage, [CachedActionItemsStorage] $cachedActionItemsStorage, [Logger] $logger) : base($cfgPath, $logger)
    {
        $this.ActionItemsStorage = $actionItemsStorage
        $this.CachedActionItemsStorage = $cachedActionItemsStorage
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
            $this.Logger.LogInfo("NetProjectsStorage saved nothing because input solutions array is empty")
            return 
        }
         
        foreach($nSolution in $nSolutions)
        {
            $this.CachedActionItemsStorage.Restore($nSolution, [ActionItemType]::NSolution)
            foreach($nProject in $nSolution.NProjects)
            {
                $this.CachedActionItemsStorage.Restore($nProject, [ActionItemType]::NProj)
            }
        }

        $this.Solutions = $nSolutions
        $this.Save()
        
         #save actionItems
        [List[NProject]] $allNewProjects = @()

        $this.Solutions | ForEach-Object{
            $allNewProjects.AddRange($_.NProjects)
        }
        $this.ActionItemsStorage.Add($this.Solutions, [ActionItemType]::NSolution)
        $this.ActionItemsStorage.Add($allNewProjects, [ActionItemType]::NProj)
        $this.Logger.LogInfo("New .Net solutions ($($this.Solutions.Count)) have been successfully saved to file: $($this.ConfigFullPath)")
    }

    Save()
    {
        [NetSolutionsContainer] $nSolutionsContainer = [NetSolutionsContainer]::new()
        $nSolutionsContainer.NetSolutions = $this.Solutions

        [XmlHelper]::Serialize($nSolutionsContainer, $this.ConfigFullPath)
    }

    DeleteSolutions([string] $folderPath)
    {
        if($this.Solutions.Count -eq 0 -or [string]::IsNullOrEmpty($folderPath))
        { return }
        
        $folderPath = $folderPath.ToLower()
        $oldSolutionsCount = $this.Solutions.Count

        $this.Solutions = $this.Solutions | Where-Object { (-not $_.Path.ToLower().StartsWith($folderPath)) }
        $this.Solutions = [CH]::Ternary(($this.Solutions -eq $null), @(), $this.Solutions) 
        $this.Save()

        $deletedSolutionsCount = $oldSolutionsCount - $this.Solutions.Count
        $this.Logger.LogInfo("Old .Net solutions ($($deletedSolutionsCount)) matched by path: '$($folderPath)' have been deleted")

        $this.ActionItemsStorage.Delete($folderPath, @([ActionItemType]::NSolution, [ActionItemType]::NProj))
    }
}