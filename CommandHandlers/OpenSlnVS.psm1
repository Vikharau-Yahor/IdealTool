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
    hidden [VisualStudioTool] $VisualStudioTool
    hidden [ActionItemsStorage] $ActionItemsStorage

    OpenSlnVS ([StorageProvider]$storageProvider, [Logger] $logger, [string]$commandParams) : base($storageProvider, $logger, $commandParams)
    { 
        $this.VisualStudioTool = [VisualStudioTool]::new($logger)
        $this.ActionItemsStorage = $this.StorageProvider.GetActionItemsStorage()
    }

    #overridden
    [void] Handle()
    { 
        [string[]] $solutionAliases = $this.ExtractItems($this.CommandParams)

        if($solutionAliases.Count -eq 0)
        { 
            $this.Logger.LogInfo("You must specify at least one solution alias for this command")
            return
        }

        foreach($solutionAlias in $solutionAliases)
        {
            if([string]::IsNullOrWhiteSpace($solutionAlias))
            { 
                $this.Logger.LogInfo("You must specify solution alias for this command")
                continue
            }

            $slnActionItem = $this.ActionItemsStorage.GetByAlias($solutionAlias, [ActionItemType]::NSolution)
            
            if($slnActionItem -eq $null)
            {
                $this.Logger.LogInfo("Solution with alias $solutionAlias has't been found")
                continue
            }
    
            $this.VisualStudioTool.Open($slnActionItem.Path) 
        }       
    }
}