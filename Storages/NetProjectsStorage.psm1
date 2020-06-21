using namespace System.Collections.Generic

using module .\_AbstractActionItemsStorage.psm1
using module .\ActionItemsStorage.psm1
using module .\CachedActionItemsStorage.psm1
using module ..\Models\ActionItem.psm1
using module ..\Models\ActionItemType.psm1
using module ..\Models\NetModels.psm1
using module ..\Utils\Helpers\XmlHelper.psm1
using module ..\Utils\Helpers\CommonHelper.psm1
using module ..\Logger.psm1

class NetProjectsStorage : AbstractActionItemsStorage
{
    hidden [Dictionary[string, NSolution]] $Solutions
    hidden [Dictionary[string, NProject]] $Projects
    
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
        $this.Solutions = [Dictionary[string, NSolution]]::new()
        $this.Projects = [Dictionary[string, NProject]]::new()

        if(-not (Test-Path -Path $this.ConfigFullPath))
        { return }
               
        try
        {
            [DotNetItemsContainer]$container = [XmlHelper]::Deserialize([DotNetItemsContainer], $this.ConfigFullPath)
            
            if( $container -eq $null -or $container.NetSolutions -eq $null -or $container.NetProjects -eq $null)
            { return }

            foreach($solution in $container.NetSolutions)
            {
                $relatedActionItem = $this.ActionItemsStorage.GetById($solution.Id)
                $solution.SetInitialBasicData($relatedActionItem)
                $this.Solutions.Add($solution.Id, $solution)
            }

            foreach($project in $container.NetProjects)
            {
                $relatedActionItem = $this.ActionItemsStorage.GetById($project.Id)
                $project.SetInitialBasicData($relatedActionItem)
                $this.Projects.Add($project.Id, $project)
            }
        }
        catch [System.Exception]
        {
            $this.Logger.LogError("Net projects deserialization has been failed from file: $($this.ConfigFullPath). Exception:$($_.Exception)")         
        }
    }

    Add([DotNetItemsContainer] $dotNetItemsContainer)
    {
        if($dotNetItemsContainer -eq $null)
        { 
            $this.Logger.LogInfo("NetProjectsStorage saved nothing because input solutions/projects container is empty")
            return 
        }       
        
        [List[ActionItem]] $newActionItems = @()
        foreach($nSolution in $dotNetItemsContainer.NetSolutions)
        {
            if($this.Solutions.ContainsKey($nSolution.Id))
            {
                $this.Logger.LogError("NetProjectsStorage.Add(DotNetItemsContainer): solution with id '$($nSolution.Id)' already exists in storage")
                continue   
            }
            $baseData = $nSolution.GetBaseData()
            $this.CachedActionItemsStorage.Restore($baseData)
            
            $this.Solutions.Add($nSolution.Id, $nSolution)
            $newActionItems.Add($nSolution.GetBaseData())
        }

        foreach($nProject in $dotNetItemsContainer.NetProjects)
        {
            if($this.Projects.ContainsKey($nProject.Id))
            {
                $this.Logger.LogError("NetProjectsStorage.Add(DotNetItemsContainer): project with id '$($nProject.Id)' already exists in storage")
                continue   
            }
            $baseData = $nProject.GetBaseData()
            $this.CachedActionItemsStorage.Restore($baseData)
            
            $this.Projects.Add($nProject.Id, $nProject)
            $newActionItems.Add($nProject.GetBaseData())
        }

        $this.Save()
        
        $this.Logger.LogInfo("New .Net solutions ($($dotNetItemsContainer.NetSolutions.Count)) have been successfully saved to file: $($this.ConfigFullPath)")
        $this.Logger.LogInfo("New .Net projects ($($dotNetItemsContainer.NetProjects.Count)) have been successfully saved to file: $($this.ConfigFullPath)")
        
        #save actionItems
        $this.ActionItemsStorage.Add($newActionItems)
    }

    Save()
    {
        [DotNetItemsContainer] $nSolutionsContainer = [DotNetItemsContainer]::new()
        $nSolutionsContainer.NetSolutions = $this.Solutions.Values
        $nSolutionsContainer.NetProjects = $this.Projects.Values

        [XmlHelper]::Serialize($nSolutionsContainer, $this.ConfigFullPath)
    }

    Delete([string] $folderPath)
    {
        if($this.Solutions.Count -eq 0 -or [string]::IsNullOrEmpty($folderPath))
        { return }
        
        $folderPath = $folderPath.ToLower()
        $oldSolutionsCount = $this.Solutions.Count
        $oldProjectsCount = $this.Projects.Count

        $solutionsToDelete = $this.Solutions.Values | Where-Object { $_.GetBaseData().Path.ToLower().StartsWith($folderPath) }
        $solutionsToDelete = [CH]::Ternary(($solutionsToDelete -eq $null), @(), $solutionsToDelete)   
        foreach($solution in $solutionsToDelete) 
        { $this.Solutions.Remove($solution.Id) }

        $projectsToDelete = $this.Projects.Values | Where-Object { $_.GetBaseData().Path.ToLower().StartsWith($folderPath) }
        $projectsToDelete = [CH]::Ternary(($projectsToDelete -eq $null), @(), $projectsToDelete) 
        foreach($project in $projectsToDelete) 
        { $this.Projects.Remove($project.Id) }
            
        $this.Save()

        $this.Logger.LogInfo("Old .Net solutions ($($solutionsToDelete.Count)) matched by path: '$($folderPath)' have been deleted")
        $this.Logger.LogInfo("Old .Net projects ($($projectsToDelete.Count)) matched by path: '$($folderPath)' have been deleted")

        #delete actionItems
        $this.ActionItemsStorage.Delete($folderPath, @([ActionItemType]::NSolution, [ActionItemType]::NProj))
    }
}