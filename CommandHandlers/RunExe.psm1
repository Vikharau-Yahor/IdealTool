using module .\_CommandHandlerBase.psm1
using module ..\Global.psm1
using module ..\Models\ActionItemType.psm1
using module ..\Models\NetModels.psm1
using module ..\Storages\_StorageProvider.psm1
using module ..\Storages\ActionItemsStorage.psm1
using module ..\Storages\NetProjectsStorage.psm1
using module ..\Utils\Helpers\StringHelper.psm1
using module ..\Utils\Tools\DotNetTool.psm1
using module ..\Logger.psm1

class RunExe : CommandHandlerBase
{
    hidden [DotNetTool] $DotNetTool
    hidden [NetProjectsStorage] $DotNetStorage

    RunExe ([StorageProvider]$storageProvider, [Logger] $logger, [string]$commandParams) : base($storageProvider, $logger, $commandParams)
    { 
        $this.DotNetTool = [DotNetTool]::new($logger)
        $this.DotNetStorage = $this.StorageProvider.GetNetProjectsStorage()
    }

    #overridden
    [void] Handle()
    { 
        [string[]] $projectAliases = $this.ExtractParams($this.CommandParams)

        if($projectAliases.Count -eq 0)
        { 
            $this.Logger.LogInfo("You must specify at least one project alias for this command")
            return
        }

        foreach($projectAlias in $projectAliases)
        {
            $this.RunMsOrExe($projectAlias)
        }
    }

    [void] RunMsOrExe([string] $projectAlias)
    {
        [ActionItemsStorage]$actionItemsStorage = $this.StorageProvider.GetActionItemsStorage()
        $projectActionItem = $actionItemsStorage.GetByAlias($projectAlias, [ActionItemType]::NProj)
        
        if($projectActionItem -eq $null)
        {
            $this.Logger.LogInfo("Project with alias $projectAlias has't been found")
            return
        }     

        [NProject ]$project = $this.DotNetStorage.GetProjectById($projectActionItem.Id)
        
        if($project -eq $null)
        { 
            $this.Logger.LogInfo("Project with id $($projectActionItem.Id) has't been found")
            return 
        }
        
        if($project.Type -ne [NProjectType]::ExeOrWinService)
        {
            $this.Logger.LogInfo("Can't run project because it must be executable or winService")
            return
        }
        # must run in separate powershell window  
        $this.DotNetTool.RunProject($projectActionItem.Path, $true)    
    }
}