using module .\_CommandHandlerBase.psm1
using module ..\Global.psm1
using module ..\Utils\StringHelper.psm1
using module ..\Storages\_StorageProvider.psm1
using module ..\Logger.psm1

class ScanHandler : CommandHandlerBase
{
    [string[]]$gitPathesElementsIgnoreList = @("node_modules")

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

        $this.SearchGitRepos($folderFullPath)
       
    }

    [void] SearchGitRepos([string] $searchPath)
    {
        $foundItems = Get-ChildItem -Path $searchPath\.git -Recurse
        $gitReposPathes = $foundItems | Where-Object { $this.IsNotInIgnoreList($_.FullName) }
        
        $this.Logger.LogInfo("$($gitReposPathes.Length)")   
    }

    [bool] IsNotInIgnoreList([string] $path)
    {
        return ($this.gitPathesElementsIgnoreList | Where-Object { $path.Contains($_) }).Count -eq 0
    }
}