using namespace System.Collections.Generic
using namespace System.IO

using module .\_CommandHandlerBase.psm1
using module ..\Models\GitRepo.psm1
using module ..\Models\EntityType.psm1
using module ..\Storages\_StorageProvider.psm1
using module ..\Utils\Helpers\XMLHelper.psm1
using module ..\Utils\Helpers\EntityHelper.psm1
using module ..\Utils\Searchers\GitReposSearcher.psm1
using module ..\Global.psm1
using module ..\Logger.psm1

class ScanHandler : CommandHandlerBase
{
    [GitReposSearcher] $GitReposSearcher

    ScanHandler ([StorageProvider]$storageProvider, [Logger] $logger, [string]$commandParams) : base($storageProvider, $logger, $commandParams)
    { 
        $this.GitReposSearcher = [GitReposSearcher]::new($logger)
    }

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

        [GitRepo[]] $gitRepos = $this.GitReposSearcher.SearchGitRepos($folderFullPath)    
        $this.storageProvider.GetGitReposStorage().Save($gitRepos)
    }

}
