using namespace System.Collections.Generic

using module .\ActionItemsStorage.psm1
using module .\CachedActionItemsStorage.psm1
using module ..\Models\ActionItemType.psm1
using module ..\Models\GitRepo.psm1
using module ..\Utils\Helpers\XmlHelper.psm1
using module ..\Utils\Helpers\CommonHelper.psm1
using module ..\Logger.psm1

class GitReposStorage
{ 
    [string] $ConfigFullPath
    [GitRepo[]] $GitRepos
    [Logger] $Logger
    [ActionItemsStorage] $ActionItemsStorage
    [CachedActionItemsStorage] $CachedActionItemsStorage

    GitReposStorage([string]$cfgPath, [ActionItemsStorage] $actionItemsStorage, [CachedActionItemsStorage] $cachedActionItemsStorage, [Logger] $logger)
    {
        $this.ConfigFullPath = $cfgPath
        $this.ActionItemsStorage = $actionItemsStorage
        $this.CachedActionItemsStorage = $cachedActionItemsStorage
        $this.Logger = $logger
        $this.Reload()
    }

    Reload()
    {
        $this.GitRepos = @()

        if(-not (Test-Path -Path $this.ConfigFullPath))
        { return }
               
        try
        {
            [GitReposContainer]$gitReposContainer = [XmlHelper]::Deserialize([GitReposContainer], $this.ConfigFullPath)
            
            if( $gitReposContainer -eq $null -or $gitReposContainer.GitRepositories -eq $null)
            { return }

            $this.GitRepos = $gitReposContainer.GitRepositories
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
        
        foreach($gitRepo in $gitRepos)
        {
            $this.CachedActionItemsStorage.Restore($gitRepo, [ActionItemType]::Git)
        }

        $this.GitRepos = $gitRepos
        $this.Save()
        $this.Logger.LogInfo("New git repositories ($($this.GitRepos.Count)) have been successfully saved to file: $($this.ConfigFullPath)")

        #save actionItems
        $this.ActionItemsStorage.Add($this.GitRepos, [ActionItemType]::Git)
    }

    Delete([string] $folderPath)
    {
        if($this.GitRepos.Count -eq 0 -or [string]::IsNullOrEmpty($folderPath))
        { return }
        
        $folderPath = $folderPath.ToLower()
        $oldReposCount = $this.GitRepos.Count
       
        $this.GitRepos = $this.GitRepos | Where-Object { (-not $_.Path.ToLower().StartsWith($folderPath)) }
        $this.GitRepos = [CH]::Ternary(($this.GitRepos -eq $null), @(), $this.GitRepos) 
        $this.Save()

        $deletedReposCount = $oldReposCount - $this.GitRepos.Count
        $this.Logger.LogInfo("Old Git repositories ($($deletedReposCount)) matched by path: '$($folderPath)' have been deleted")

        $this.ActionItemsStorage.Delete($folderPath, @([ActionItemType]::Git))
    }

    Save()
    {
        [GitReposContainer] $gitReposContainer = [GitReposContainer]::new()
        $gitReposContainer.GitRepositories = $this.GitRepos

        [XmlHelper]::Serialize($gitReposContainer, $this.ConfigFullPath)
    }
}