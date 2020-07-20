using module .\_CommandHandlerBase.psm1
using module .\_StandardCommandHandler.psm1
using module ..\Models\ActionItemType.psm1
using module ..\Models\CommandsEnum.psm1
using module ..\Models\CommandModifiersEnum.psm1
using module ..\Storages\_StorageProvider.psm1
using module ..\Storages\ActionItemsStorage.psm1
using module ..\Utils\Tools\DotNetTool.psm1
using module ..\Logger.psm1

#default: solution build and debug mode
class NetBuildHandler : StandardCommandHandler
{
    hidden [DotNetTool] $DotNetTool
    hidden [ActionItemsStorage] $ActionItemsStorage

    #flags
    [bool] $AreProjectsProcessing = $false
    [bool] $IsReleaseMode = $false
    
    NetBuildHandler ([StorageProvider]$storageProvider, [Logger] $logger, [string]$commandParams) : base($storageProvider, $logger, $commandParams, [CommandsEnum]::NetBuild)
    { 
        $this.DotNetTool = [DotNetTool]::new($logger)
        $this.ActionItemsStorage = $this.StorageProvider.GetActionItemsStorage()
        $this.SetupFlags()
    }

    SetupFlags()
    {
        if($this.ActiveModifiers.Contains([CommandModifiersEnum]::M01))
        { 
            $this.AreProjectsProcessing = $true
        }
        if($this.ActiveModifiers.Contains([CommandModifiersEnum]::M02))
        { 
            $this.IsReleaseMode = $true
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
                $this.BuildProject($alias)
            }
            else {
                $this.BuildSolution($alias)
            }
        }       
    }

    hidden BuildProject([string] $projectAlias)
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
    
            $this.DotNetTool.Build($projActionItem.Path, $this.IsReleaseMode) 
    }

    
    hidden BuildSolution([string] $solutionAlias)
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

        $this.DotNetTool.Build($slnActionItem.Path, $this.IsReleaseMode) 
    }
}