using namespace System.Collections.Generic
using namespace System.IO

using module .\_CommandHandlerBase.psm1
using module ..\Models\GitRepo.psm1
using module ..\Models\EntityType.psm1
using module ..\Storages\_StorageProvider.psm1
using module ..\Utils\XMLHelper.psm1
using module ..\Utils\EntityHelper.psm1
using module ..\Global.psm1
using module ..\Logger.psm1

class ScanHandler : CommandHandlerBase
{
    [string[]]$gitPathesElementsIgnoreList = @("node_modules")
    [string] $gitConfigRepoNameKey = "url"
    [string] $gitNameSeparatorInUrl = ":"
    [string] $gitConfigRelativePath = "\.git\config"
    [string] $gitConfigFolder = ".git"

    ScanHandler ([StorageProvider]$storageProvider, [Logger] $logger, [string]$commandParams) : base($storageProvider, $logger, $commandParams)
    {  }

    #overridden
    [void] Handle()
    { 
        $params = $this.CommandParams

        if([string]::IsNullOrWhiteSpace($params))
        { 
            $this.Logger.LogInfo("You must specify full path to folder to scan")
            return
        }
        
        $folderFullPath = $params.Trim()

        if(-not (Test-Path -Path $folderFullPath))
        { 
            $this.Logger.LogInfo("You specified invalid or non-existant path: '$folderFullPath'") 
            return
        }

        $gitRepos = $this.SearchGitRepos($folderFullPath)    
        $this.storageProvider.GetGitReposStorage().Save($gitRepos)
    }

    [GitRepo[]] SearchGitRepos([string] $searchPath)
    {

        $foundItems = Get-ChildItem -Path $searchPath $this.gitConfigFolder -Recurse -Directory -Force
        $gitReposFolders = $foundItems | Where-Object { $this.IsNotInIgnoreList($_.FullName) }      
        [List[GitRepo]] $gitRepos = @()

        $gitReposFolders | ForEach-Object {
            $gitFolder = $_.FullName | Split-Path
            [GitRepo]$gitRepo = [GitRepo]::new()
            $gitRepoUrl = $this.GetGitRepoUrl($gitFolder)

            $gitRepo.Path = $gitFolder
            $gitRepo.Url = $gitRepoUrl
            $gitRepo.Name = $this.ExtractGitName($gitRepoUrl)

            $gitRepo.Id = [EntityHelper]::GenerateId([EntityType]::Git, $gitRepo.Name, $gitRepo.Path)
            $gitRepos.Add($gitRepo)
        }
        $this.Logger.LogInfo("Git-repositories found: $($gitRepos.Count)") 
        return $gitRepos.ToArray()  
    }

    [string] ExtractGitName([string] $gitUrlStr)
    {
        $gitRepoName=''
        if($gitUrlStr.StartsWith('git'))
        {
            $gitRepoName = $gitUrlStr.Split(@($this.gitNameSeparatorInUrl))[1].Trim()
        }
        else
        {
            $gitNameparts = $gitUrlStr.Split(@('/'),[System.StringSplitOptions]::RemoveEmptyEntries) | Select -Skip 2
            $gitRepoName = [string]::Join('/', $gitNameparts)
        }
        return $gitRepoName
    }

    [string] GetGitRepoUrl([string] $repoPath)
    {
        [string[]]$gitConfigContent = [File]::ReadAllLines($repoPath + $this.gitConfigRelativePath)

        [string] $configUrlLine = $gitConfigContent | Where-Object { $_.Trim().StartsWith($this.gitConfigRepoNameKey) } | Select-Object -First 1

        $gitRepoUrl = $configUrlLine.Split(@('='))[1].Trim()
        return $gitRepoUrl
    }


    [bool] IsNotInIgnoreList([string] $path)
    {
        return ($this.gitPathesElementsIgnoreList | Where-Object { $path.Contains($_) }).Count -eq 0
    }
}
