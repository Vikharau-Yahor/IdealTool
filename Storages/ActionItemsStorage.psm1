using namespace System.Linq
using namespace System.Collections.Generic

using module ..\Models\_BaseActionItem.psm1
using module ..\Models\ActionItem.psm1
using module ..\Models\ActionItemType.psm1
using module ..\Utils\Helpers\XmlHelper.psm1
using module ..\Logger.psm1

class ActionItemsStorage
{ 
    [string] $ConfigFullPath
    [List[ActionItem]] $ActionItems
    [Logger] $Logger

    ActionItemsStorage([string]$cfgPath, [Logger] $logger)
    {
        $this.ConfigFullPath = $cfgPath
        $this.Logger = $logger
        $this.Reload()
    }

    Reload()
    {
        $this.ActionItems = @()

        if(-not (Test-Path -Path $this.ConfigFullPath))
        { return }
               
        try
        {
            [ActionItemsContainer]$actionItemsContainer = [XmlHelper]::Deserialize([ActionItemsContainer], $this.ConfigFullPath)
            
            if( $null -eq $actionItemsContainer -or $null -eq $actionItemsContainer.ActionItems)
            { return }

            $this.ActionItems.AddRange($actionItemsContainer.ActionItems)
        }
        catch [System.Exception]
        {
            $this.Logger.LogError("Action Items deserialization has been failed from file: $($this.ConfigFullPath). Exception:$($_.Exception)")         
        }
    }

    Save()
    {
        [ActionItemsContainer] $actionItemsContainer = [ActionItemsContainer]::new()
        $actionItemsContainer.ActionItems = $this.ActionItems.ToArray()

        [XmlHelper]::Serialize($actionItemsContainer, $this.ConfigFullPath)
        $this.Logger.LogInfo("New action items have been saved to file: $($this.ConfigFullPath)")
    }

    Add([BaseActionItem] $baseActionItem, [ActionItemType] $actionItemType )
    {
        if($baseActionItem -eq $null)
        { return; }

        $this.Add(@($baseActionItem), $actionItemType)
    }
    
    Add([BaseActionItem[]] $baseActionItems, [ActionItemType] $actionItemType )
    {
        [List[ActionItem]] $newActionItems = @()

        $baseActionItems | ForEach-Object {
            $newActionItems.Add([ActionItem]::new($_, $actionItemType))
        }

        $this.Add($newActionItems)
    }

    Add([ActionItem[]] $actionItems)
    {  
        if($null -eq $actionItems -or $actionItems.Length -eq 0)
        {  return; }

        [List[string]] $currentActionItemsKeys = @() 
        $this.ActionItems | ForEach-Object { $currentActionItemsKeys.Add($_.Id) }
        
        if($currentActionItemsKeys -eq $null)
        { return; }

        [List[ActionItem]] $newActionItems = @()
        $newActionItems = $actionItems | Where-Object { -not $currentActionItemsKeys.Contains($_.Id) }
        $this.Logger.LogInfo("New action items count for saving: $($newActionItems.Count)")
        
        if($newActionItems.Count -eq 0)
        { return; }

        $this.ActionItems.AddRange($newActionItems)
        $this.ActionItems = $this.ActionItems | Sort-Object -Property Name
        $this.Save()
    }

    [ActionItem[]] GetNonAliasedActionItems()
    {
        [ActionItem[]] $result = $this.ActionItems | Where-Object { [string]::IsNullOrEmpty($_.Alias) }
        return $result
    }
}