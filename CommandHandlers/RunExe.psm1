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
    [DotNetTool] $DotNetTool
    
    RunExe ([StorageProvider]$storageProvider, [Logger] $logger, [string]$commandParams) : base($storageProvider, $logger, $commandParams)
    { 
        $this.DotNetTool = [DotNetTool]::new($logger)
    }

    #overridden
    [void] Handle()
    { 
        $solutionAlias = $this.CommandParams

        if([string]::IsNullOrWhiteSpace($solutionAlias))
        { 
            $this.Logger.LogInfo("You must specify project alias for this command")
            return
        }
        [ActionItemsStorage]$actionItemsStorage = $this.StorageProvider.GetActionItemsStorage()
        $projectActionItem = $actionItemsStorage.GetByAlias($solutionAlias, [ActionItemType]::NProj)
        
        if($projectActionItem -eq $null)
        {
            $this.Logger.LogInfo("Solution with alias $solutionAlias has't been found")
            return
        }     

        [NetProjectsStorage]$dotNetStorage = $this.StorageProvider.GetNetProjectsStorage()
        [NProject ]$project = $dotNetStorage.GetProjectById($projectActionItem.Id)
        
        if($project -eq $null)
        { return }
        
        if($project.Type -ne [NProjectType]::ExeOrWinService)
        {
            $this.Logger.LogInfo("Can't run project because it must be executable or winService")
            return
        }
        # must run in separate powershell window  
        $this.DotNetTool.RunProject($projectActionItem.Path, "Debug")

    }
}