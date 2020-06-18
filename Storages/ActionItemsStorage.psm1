using namespace System.Linq
using namespace System.Collections.Generic

using module .\_AbstractActionItemsStorage.psm1
using module ..\Models\_BaseActionItem.psm1
using module ..\Models\ActionItem.psm1
using module ..\Models\ActionItemType.psm1
using module ..\Utils\Helpers\XmlHelper.psm1
using module ..\Utils\Helpers\CommonHelper.psm1
using module ..\Logger.psm1

class ActionItemsStorage : AbstractActionItemsStorage
{ 
    [List[ActionItem]] $ActionItems

    ActionItemsStorage([string]$cfgPath, [Logger] $logger) : base($cfgPath, $logger)
    {
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
        
        if($newActionItems.Count -eq 0)
        { return; }

        $this.ActionItems.AddRange($newActionItems)
        $this.ActionItems = $this.ActionItems | Sort-Object -Property Name
        $this.Save()

        $firstActionItem = $actionItems | Select-Object -First 1
        $actionTypeString = $firstActionItem.AIType.ToString()
        $this.Logger.LogInfo("New action items ($($newActionItems.Count)) with type $actionTypeString have been added to file: $($this.ConfigFullPath)")
    }

    [ActionItem[]] GetNonAliasedActionItems()
    {
        [ActionItem[]] $result = @()
        
        if($this.ActionItems -eq $null -or $this.ActionItems.Count -eq 0)
        { return $result }

        [ActionItem[]] $result = $this.ActionItems | Where-Object { ([string]::IsNullOrEmpty($_.Alias) -and $_.IsActive) } | Sort-Object -Property AIType, Name
        return $result
    }

    [ActionItem] GetByAlias([string] $alias, [ActionItemType] $itemType)
    {
        [ActionItem] $result = $null

        $result = $this.ActionItems | Where-Object { ($_.Alias -eq $alias -and $_.IsActive) } | Select-Object -First 1
        return $result
    }

    Delete([string] $folderPath, [ActionItemType[]] $actionItemTypes)
    {
        if(($this.ActionItems.Count -eq 0 -or [string]::IsNullOrEmpty($folderPath)) -or $actionItemTypes -eq $null)
        { return }
        
        $folderPath = $folderPath.ToLower()
        $oldActionItemsCount = $this.ActionItems.Count
        $this.ActionItems = $this.ActionItems | Where-Object { (-not ($_.Path.ToLower().StartsWith($folderPath) -and $actionItemTypes.Contains($_.AIType))) }
        $this.ActionItems = [CH]::Ternary(($this.ActionItems -eq $null), @(), $this.ActionItems) 
        $this.Save()

        $deletedActionItemsCount =  $oldActionItemsCount - $this.ActionItems.Count
        $this.Logger.LogInfo("Old action items ($($deletedActionItemsCount)) matched by path: '$($folderPath)' have been deleted")
    }
}