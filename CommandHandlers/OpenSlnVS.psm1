using module .\_CommandHandlerBase.psm1
using module ..\Global.psm1
using module ..\Models\ActionItemType.psm1
using module ..\Storages\_StorageProvider.psm1
using module ..\Storages\ActionItemsStorage.psm1
using module ..\Utils\Helpers\StringHelper.psm1
using module ..\Utils\Tools\VisualStudioTool.psm1
using module ..\Logger.psm1

class OpenSlnVS : CommandHandlerBase
{
    [VisualStudioTool] $VisualStudioTool
    
    OpenSlnVS ([StorageProvider]$storageProvider, [Logger] $logger, [string]$commandParams) : base($storageProvider, $logger, $commandParams)
    { 
        $this.VisualStudioTool = [VisualStudioTool]::new($logger)
    }

    #overridden
    [void] Handle()
    { 
        $solutionAlias = $this.CommandParams

        if([string]::IsNullOrWhiteSpace($solutionAlias))
        { 
            $this.Logger.LogInfo("You must specify solution alias for this command")
            return
        }
        [ActionItemsStorage]$actionItemsStorage = $this.StorageProvider.GetActionItemsStorage()
        $slnActionItem = $actionItemsStorage.GetByAlias($solutionAlias, [ActionItemType]::NSolution)
        
        if($slnActionItem -eq $null)
        {
            $this.Logger.LogInfo("Solution with alias $solutionAlias has't been found")
            return
        }

        $this.VisualStudioTool.Open($slnActionItem.Path)        
    }
}