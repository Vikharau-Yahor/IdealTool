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
        #$this.Logger.LogInfo("New cached action items have been saved to file: $($this.ConfigFullPath)")
    }

    [BaseActionItem] Restore([BaseActionItem] $baseActionItem, [ActionItemType] $actionItemType)
    {
        if($baseActionItem -eq $null -or -not $this.CachedActionItems.ContainsKey($baseActionItem.Id))
        { return $baseActionItem }

        [CachedActionItem] $cachedItem = $this.CachedActionItems[$baseActionItem.Id]

        $baseActionItem.Alias = $cachedItem.CachedAlias
        $baseActionItem.IsActive = $cachedItem.CachedIsActive
        return $baseActionItem
    }

}