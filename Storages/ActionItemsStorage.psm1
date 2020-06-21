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
    hidden [Dictionary[string, ActionItem]] $ActionItems

    ActionItemsStorage([string]$cfgPath, [Logger] $logger) : base($cfgPath, $logger)
    {
        $this.Reload()
    }

    Reload()
    {
        $this.ActionItems = [Dictionary[string, ActionItem]]::new()

        if(-not (Test-Path -Path $this.ConfigFullPath))
        { return }
               
        try
        {
            [ActionItemsContainer]$actionItemsContainer = [XmlHelper]::Deserialize([ActionItemsContainer], $this.ConfigFullPath)
            
            if( $null -eq $actionItemsContainer -or $null -eq $actionItemsContainer.ActionItems)
            { return }

            foreach($deserealiasedItem in $actionItemsContainer.ActionItems) {
                if($this.ActionItems.ContainsKey($deserealiasedItem.Id))
                {
                    $this.Logger.LogError("Action Items Reload(): Action Item with Id: $($deserealiasedItem.Id) already exists in storage dictionary")
                    continue   
                }
                $this.ActionItems.Add($deserealiasedItem.Id, $deserealiasedItem)   
            }
        }
        catch [System.Exception]
        {
            $this.Logger.LogError("Action Items deserialization has been failed from file: $($this.ConfigFullPath). Exception:$($_.Exception)")         
        }
    }

    Save()
    {
        [ActionItemsContainer] $actionItemsContainer = [ActionItemsContainer]::new()
        $actionItemsContainer.ActionItems = $this.ActionItems.Values

        [XmlHelper]::Serialize($actionItemsContainer, $this.ConfigFullPath)
    }
    
    Add([ActionItem[]] $actionItems)
    {  
        if($null -eq $actionItems -or $actionItems.Length -eq 0)
        {  return; }

        foreach($newActionItem in $actionItems)
        {
            if($this.ActionItems.ContainsKey($newActionItem.Id))
            {
                $this.Logger.LogError("Action Items Add(ActionItem[]]): Action Item with Id '$($newActionItem.Id)' already exists in storage dictionary")
                continue   
            }
            $this.ActionItems.Add($newActionItem.Id,$newActionItem)
        }

        $this.ActionItems = $this.ActionItems | Sort-Object -Property Key
        $this.Save()

        $this.Logger.LogInfo("New action items ($($actionItems.Count)) have been added to file: $($this.ConfigFullPath)")
    }

    [ActionItem[]] GetNonAliasedActionItems()
    {
        [ActionItem[]] $result = @()
        
        if($this.ActionItems -eq $null -or $this.ActionItems.Count -eq 0)
        { return $result }

        [ActionItem[]] $result = $this.ActionItems.Values | Where-Object { ([string]::IsNullOrEmpty($_.Alias) -and $_.IsActive) } | Sort-Object -Property AIType, Name
        return $result
    }

    [ActionItem] GetByAlias([string] $alias, [ActionItemType] $itemType)
    {
        [ActionItem] $result = $null

        $result = $this.ActionItems.Values | Where-Object { ($_.Alias -eq $alias -and $_.IsActive) } | Select-Object -First 1
        return $result
    }

    
    [ActionItem] GetById([string] $id)
    {
        [ActionItem] $result = $null
        if(-not ($this.ActionItems.ContainsKey($id)))
        {
            $this.Logger.LogError("ActionItemsStorage.GetById(string): Action Item with Id '$($id)' doesn't exists in the storage")
            return $result   
        }
        $result = $this.ActionItems[$id]
        return $result
    }

    Delete([string] $folderPath, [ActionItemType[]] $actionItemTypes)
    {
        if(($this.ActionItems.Count -eq 0 -or [string]::IsNullOrEmpty($folderPath)) -or $actionItemTypes -eq $null)
        { return }
        
        $folderPath = $folderPath.ToLower()
        $oldActionItemsCount = $this.ActionItems.Count
        $itemsToDelete = $this.ActionItems.Values | Where-Object { ($_.Path.ToLower().StartsWith($folderPath) -and $actionItemTypes.Contains($_.AIType)) }
        
        if($itemsToDelete -eq $null)
        { return; }

        foreach($itemToDelete in $itemsToDelete)
        {
            $this.ActionItems.Remove($itemToDelete.Id)
        }

        $this.ActionItems = [CH]::Ternary(($this.ActionItems -eq $null), [ActionItemsContainer]::new(), $this.ActionItems) 
        $this.Save()

        $this.Logger.LogInfo("Old action items ($($itemsToDelete.Count)) matched by path: '$($folderPath)' have been deleted")
    }
}