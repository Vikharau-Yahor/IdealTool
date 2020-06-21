using namespace System.Collections.Generic
using namespace System.IO

using module ..\Helpers\XMLHelper.psm1
using module ..\Helpers\ActionItemHelper.psm1
using module ..\..\Logger.psm1
using module ..\..\Models\ActionItem.psm1
using module ..\..\Models\ActionItemType.psm1
using module ..\..\Models\GitRepo.psm1

class GitReposSearcher
{
    hidden [string[]]$gitPathesElementsIgnoreList = @("node_modules")
    hidden [string] $gitConfigRepoNameKey = "url"
    hidden [string] $gitNameSeparatorInUrl = ":"
    hidden [string] $gitConfigRelativePath = "\.git\config"
    hidden [string] $gitConfigFolder = ".git"

    hidden [Logger] $logger

    GitReposSearcher([Logger] $logger)
    {
        $this.logger = $logger
    }

    [GitRepo[]] SearchGitRepos([string] $searchPath)
    {
        $this.Logger.LogInfo("Start Git-repositories search") 
        $foundItems = Get-ChildItem -Path $searchPath $this.gitConfigFolder -Recurse -Directory -Hidden -ErrorAction Continue
        $gitReposFolders = $foundItems | Where-Object { $this.IsNotInIgnoreList($_.FullName) }      
        [List[GitRepo]] $gitRepos = @()

        $gitReposFolders | ForEach-Object {
            $gitFolder = $_.FullName | Split-Path

            [GitRepo]$gitRepo = [GitRepo]::new()
            #setup base data
            $gitRepoUrl = $this.GetGitRepoUrl($gitFolder)
            $name = $this.ExtractGitName($gitRepoUrl)
            $baseInfo = [ActionItem]::new($name, $gitFolder, $true, [ActionItemType]::Git)  
            $gitRepo.SetInitialBasicData($baseInfo)

            $gitRepo.Url = $gitRepoUrl
            $gitRepos.Add($gitRepo)
        }
        $this.Logger.LogInfo("Git-repositories found: $($gitRepos.Count)") 
        return $gitRepos.ToArray()  
    }

    hidden [string] ExtractGitName([string] $gitUrlStr)
    {
        $gitRepoName=''
        if($gitUrlStr.StartsWith('git'))
        {
            $gitRepoNameParts = $gitUrlStr.Split(@($this.gitNameSeparatorInUrl))[1].Trim()
            $gitRepoName = $gitRepoNameParts.Split(@('/'),[System.StringSplitOptions]::RemoveEmptyEntries) | Select -Last 1
        }
        else
        {
            $gitRepoName = $gitUrlStr.Split(@('/'),[System.StringSplitOptions]::RemoveEmptyEntries) | Select -Last 1
        }
        return $gitRepoName
    }

    hidden [string] GetGitRepoUrl([string] $repoPath)
    {
        [string[]]$gitConfigContent = [File]::ReadAllLines($repoPath + $this.gitConfigRelativePath)

        [string] $configUrlLine = $gitConfigContent | Where-Object { $_.Trim().StartsWith($this.gitConfigRepoNameKey) } | Select-Object -First 1

        $gitRepoUrl = $configUrlLine.Split(@('='))[1].Trim()
        return $gitRepoUrl
    }


    hidden [bool] IsNotInIgnoreList([string] $path)
    {
        return ($this.gitPathesElementsIgnoreList | Where-Object { $path.Contains($_) }).Count -eq 0
    }
}