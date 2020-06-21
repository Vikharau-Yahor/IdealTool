using namespace System.Linq
using namespace System.Collections.Generic

using module ..\Models\_BaseActionItem.psm1
using module ..\Models\ActionItem.psm1
using module ..\Models\ActionItemType.psm1
using module ..\Models\CachedActionItem.psm1
using module ..\Utils\Helpers\XmlHelper.psm1
using module ..\Logger.psm1

class CachedActionItemsStorage
{ 
    [string] $ConfigFullPath
    [Dictionary[string, CachedActionItem]] $CachedActionItems
    [Logger] $Logger

    CachedActionItemsStorage([string]$cfgPath, [Logger] $logger)
    {
        $this.ConfigFullPath = $cfgPath
        $this.Logger = $logger
        $this.Reload()
    }

    Reload()
    {
        $this.CachedActionItems = [Dictionary[string, CachedActionItem]]::new()
    
        if(-not (Test-Path -Path $this.ConfigFullPath))
        { return }
               
        try
        {
            [CachedActionItemsContainer] $cachedActionItemsContainer = [XmlHelper]::Deserialize([CachedActionItemsContainer], $this.ConfigFullPath)
            
            if( $null -eq $cachedActionItemsContainer -or $null -eq $cachedActionItemsContainer.CachedActionItems)
            { return }

            $cachedActionItemsContainer.CachedActionItems | ForEach-Object {
                $cachedItem = $_
                $this.CachedActionItems.Add($cachedItem.Id, $cachedItem)   
            }
        }
        catch [System.Exception]
        {
            $this.Logger.LogError("Cached action items deserialization has been failed from file: $($this.ConfigFullPath). Exception:$($_.Exception)")         
        }
    }

    Save()
    {
        [CachedActionItemsContainer] $cachedActionItemsContainer = [CachedActionItemsContainer]::new()
        $cachedActionItemsContainer.CachedActionItems = $this.CachedActionItems.Values

        [XmlHelper]::Serialize($cachedActionItemsContainer, $this.ConfigFullPath)
    }

    [ActionItem] Restore([ActionItem] $actionItem)
    {
        if($actionItem -eq $null -or -not $this.CachedActionItems.ContainsKey($actionItem.Id))
        { return $actionItem }

        [CachedActionItem] $cachedItem = $this.CachedActionItems[$actionItem.Id]

        $actionItem.Alias = $cachedItem.CachedAlias
        $actionItem.IsActive = $cachedItem.CachedIsActive
        return $actionItem
    }

    Update([ActionItem[]] $actionItems)
    {
        if($actionItems -eq $null -or $actionItems.Count -eq 0)
        { return }

        foreach($actionItem in $actionItems) {
            if($this.CachedActionItems.ContainsKey($actionItem.Id))
            {
                [CachedActionItem] $cachedItem = $this.CachedActionItems[$actionItem.Id]
                $cachedItem.CachedAlias = $actionItem.Alias
                $cachedItem.CachedIsActive = $actionItem.IsActive
            }
            else {
                [CachedActionItem] $newCachedItem = [CachedActionItem]::new() 
                $newCachedItem.Id = $actionItem.Id
                $newCachedItem.AIType = $actionItem.AIType
                $newCachedItem.Name = $actionItem.Name
                $newCachedItem.CachedAlias = $actionItem.Alias
                $newCachedItem.CachedIsActive = $actionItem.IsActive
                $this.CachedActionItems.Add($newCachedItem.Id, $newCachedItem)
            }
        }

        $this.Save()
    }

}