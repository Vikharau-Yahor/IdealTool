using module .\_CommandHandlerBase.psm1
using module .\_StandardCommandHandler.psm1
using module ..\Global.psm1
using module ..\Models\ActionItemType.psm1
using module ..\Models\CommandsEnum.psm1
using module ..\Models\CommandModifiersEnum.psm1
using module ..\Storages\_StorageProvider.psm1
using module ..\Storages\ActionItemsStorage.psm1
using module ..\Utils\Helpers\StringHelper.psm1
using module ..\Utils\Tools\VisualStudioTool.psm1
using module ..\Logger.psm1

class OpenVS : StandardCommandHandler
{
    hidden [VisualStudioTool] $VisualStudioTool
    hidden [ActionItemsStorage] $ActionItemsStorage

    #flags
    [bool] $AreProjectsProcessing = $false
    [bool] $AreSolutionsProcessing = $false
    
    OpenVS ([StorageProvider]$storageProvider, [Logger] $logger, [string]$commandParams) : base($storageProvider, $logger, $commandParams, [CommandsEnum]::OpenVisualStudio)
    { 
        $this.VisualStudioTool = [VisualStudioTool]::new($logger)
        $this.ActionItemsStorage = $this.StorageProvider.GetActionItemsStorage()
        $this.SetupFlags()
    }

    SetupFlags()
    {
        if($this.ActiveModifiers.Contains([CommandModifiersEnum]::M01))
        { 
            $this.AreProjectsProcessing = $true
        }
        else
        {
            $this.AreSolutionsProcessing = $true
        }
    }

    #overridden
    [void] Handle()
    { 
        [string[]] $dotNetItemsAliases = $this.Aliases

        if($dotNetItemsAliases.Count -eq 0)
        { 
            $this.Logger.LogInfo("You must specify at least one solution/project alias for this command")
            return
        }

        foreach($alias in $dotNetItemsAliases)
        {
            if($this.AreProjectsProcessing)
            {
                $this.OpenProject($alias)
            }
            else {
                $this.OpenSolution($alias)
            }
        }       
    }

    hidden OpenProject([string] $projectAlias)
    {
        if([string]::IsNullOrWhiteSpace($projectAlias))
            { 
                $this.Logger.LogInfo("You must specify project alias for this command")
                return
            }

            $projActionItem = $this.ActionItemsStorage.GetByAlias($projectAlias, [ActionItemType]::NProj)
            
            if($projActionItem -eq $null)
            {
                $this.Logger.LogInfo("Project with alias $projectAlias has't been found")
                return
            }
    
            $this.VisualStudioTool.Open($projActionItem.Path) 
    }

    
    hidden OpenSolution([string] $solutionAlias)
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