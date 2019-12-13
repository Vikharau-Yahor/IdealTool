using module .\_CommandHandlerBase.psm1
using module ..\Global.psm1
using module ..\Logger.psm1
using module ..\Storages\_StorageProvider.psm1
using module ..\Utils\XMLHelper.psm1

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
        $gitRepo1 = [gitRepo]::new()
        $gitRepo1.Name = 'Test1'
        $gitRepo1.Path = 'C:\work\Test'

        $gitRepo2 = [gitRepo]::new()
        $gitRepo2.Name = 'Test2'
        $gitRepo2.Path = 'C:\work\Test2'

        $gitRepos = [gitRepos]::new()
        $gitRepos.gitRepo = @($gitRepo1, $gitRepo2)

        [Type] $objType = $gitRepos.GetType()
        [System.Xml.Serialization.XmlSerializer] $serializer = [System.Xml.Serialization.XmlSerializer]::new($gitRepos.GetType());

        $foundItems = Get-ChildItem -Path $searchPath\.git -Recurse
        $gitReposPathes = $foundItems | Where-Object { $this.IsNotInIgnoreList($_.FullName) }      

        $this.Logger.LogInfo("$($gitReposPathes.Length)")   
    }

    [bool] IsNotInIgnoreList([string] $path)
    {
        return ($this.gitPathesElementsIgnoreList | Where-Object { $path.Contains($_) }).Count -eq 0
    }
}



class gitRepos
{
    [gitRepo[]] $gitRepo
}

class gitRepo
{
    [String] $Name
    [String] $Path
}