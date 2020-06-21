using namespace System.Collections.Generic

using module .\_AbstractActionItemsStorage.psm1
using module .\ActionItemsStorage.psm1
using module .\CachedActionItemsStorage.psm1
using module ..\Models\ActionItem.psm1
using module ..\Models\ActionItemType.psm1
using module ..\Models\GitRepo.psm1
using module ..\Utils\Helpers\XmlHelper.psm1
using module ..\Utils\Helpers\CommonHelper.psm1
using module ..\Logger.psm1

class GitReposStorage : AbstractActionItemsStorage
{ 
    hidden [Dictionary[string, GitRepo]] $GitRepos
    [ActionItemsStorage] $ActionItemsStorage
    [CachedActionItemsStorage] $CachedActionItemsStorage

    GitReposStorage([string]$cfgPath, [ActionItemsStorage] $actionItemsStorage, [CachedActionItemsStorage] $cachedActionItemsStorage, [Logger] $logger) : base($cfgPath, $logger)
    {
        $this.ActionItemsStorage = $actionItemsStorage
        $this.CachedActionItemsStorage = $cachedActionItemsStorage
        $this.Reload()
    }

    Reload()
    {
        $this.GitRepos = [Dictionary[string, GitRepo]]::new()

        if(-not (Test-Path -Path $this.ConfigFullPath))
        { return }
               
        try
        {
            [GitReposContainer]$gitReposContainer = [XmlHelper]::Deserialize([GitReposContainer], $this.ConfigFullPath)
            
            if( $gitReposContainer -eq $null -or $gitReposContainer.GitRepositories -eq $null)
            { return }

            foreach($gitRepo in $gitReposContainer.GitRepositories)
            {
                $relatedActionItem = $this.ActionItemsStorage.GetById($gitRepo.Id)
                $gitRepo.SetInitialBasicData($relatedActionItem)
                $this.GitRepos.Add($gitRepo.Id, $gitRepo)
            }
        }
        catch [System.Exception]
        {
            $this.Logger.LogError("Git repositories deserialization has been failed from file: $($this.ConfigFullPath). Exception:$($_.Exception)")         
        }
    }

    Add([GitRepo[]] $gitRepos)
    {
        if($gitRepos -eq $null -or $gitRepos.Count -eq 0)
        { 
            $this.Logger.LogInfo("GitStorage saves nothing because input gitRepos array is empty")
            return 
        }

        [List[ActionItem]] $newActionItems = @()
        foreach($gitRepo in $gitRepos)
        {
            if($this.GitRepos.ContainsKey($gitRepo.Id))
            {
                $this.Logger.LogError("GitReposStorage.Add(GitRepo[]): git repo with id '$($gitRepo.Id)' already exists in storage")
                continue   
            }
            $baseData = $gitRepo.GetBaseData()
            $this.CachedActionItemsStorage.Restore($baseData)
            
            $this.GitRepos.Add($gitRepo.Id, $gitRepo)
            $newActionItems.Add($gitRepo.GetBaseData())
        }
        
        $this.Save()
        $this.Logger.LogInfo("New git repositories ($($this.GitRepos.Count)) have been successfully saved to file: $($this.ConfigFullPath)")

        #save actionItems
        $this.ActionItemsStorage.Add($newActionItems)
    }

    Delete([string] $folderPath)
    {
        if($this.GitRepos.Count -eq 0 -or [string]::IsNullOrEmpty($folderPath))
        { return }
        
        $folderPath = $folderPath.ToLower()
        $oldReposCount = $this.GitRepos.Count
       
        $gitReposToDelete = $this.GitRepos.Values | Where-Object { $_.GetBaseData().Path.ToLower().StartsWith($folderPath) }
        $gitReposToDelete = [CH]::Ternary(($gitReposToDelete -eq $null), @(), $gitReposToDelete)   
        
        foreach($gitRepo in $gitReposToDelete) 
        { $this.GitRepos.Remove($gitRepo.Id) }
        
        $this.Save()

        $deletedReposCount = $gitReposToDelete.Count
        $this.Logger.LogInfo("Old Git repositories ($($deletedReposCount)) matched by path: '$($folderPath)' have been deleted")

        #delete actionItems
        $this.ActionItemsStorage.Delete($folderPath, @([ActionItemType]::Git))
    }

    Save()
    {
        [GitReposContainer] $gitReposContainer = [GitReposContainer]::new()
        $gitReposContainer.GitRepositories = $this.GitRepos.Values

        [XmlHelper]::Serialize($gitReposContainer, $this.ConfigFullPath)
    }

    Update([ActionItem[]] $actionItems)
    {
        throw "Update() must be implemented in inherited class"
    }
}