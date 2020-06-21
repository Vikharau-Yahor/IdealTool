using namespace System.Linq
using namespace System.Collections
using namespace System.Collections.Generic

using module .\_CommandHandlerBase.psm1
using module ..\Utils\Helpers\StringHelper.psm1
using module ..\Storages\_StorageProvider.psm1
using module ..\Storages\_AbstractActionItemsStorage.psm1
using module ..\Storages\ActionItemsStorage.psm1
using module ..\Logger.psm1
using module ..\Global.psm1
using module ..\Models\ActionItem.psm1
using module ..\Models\ActionItemType.psm1

class SetAliasHandler : CommandHandlerBase
{

    SetAliasHandler ([StorageProvider]$storageProvider, [Logger] $logger) : base($storageProvider, $logger, $null)
    {  }

    #overridden
    [void] Handle()
    { 
        $breakCommandString = [Global]::CommandBreakString
        [ActionItemsStorage] $actionItemsStorage = $this.StorageProvider.GetActionItemsStorage()
        [ActionItem[]] $unaliasedActionItems = $actionItemsStorage.GetNonAliasedActionItems()
        [List[ActionItem]] $updatedActionItems = [List[ActionItem]]::new()

        if($unaliasedActionItems.Count -eq 0)
        {
            $this.Logger.LogInfo("There are no items for setting alias") 
            return
        }

        foreach($unaliasedItem in $unaliasedActionItems)
        {
            $itemName = $unaliasedItem.Name
            $itemType = $unaliasedItem.AIType.ToString()
            $itemPath = $unaliasedItem.Path
            $this.Logger.LogSimpleText("")
            $this.Logger.LogSimpleText("Type: $itemType")
            $this.Logger.LogSimpleText("Name: $itemName")
            $this.Logger.LogSimpleText("Path: $itemPath")
            $this.Logger.LogSimpleText("Enter item alias (leave empty to ignore this item or '$breakCommandString' to stop the process):")
            [string] $userInput = Read-Host  
            
            while(-not ($this.ValidateUserInput($userInput, $unaliasedItem.AIType)))
            {
                $userInput = Read-Host "Enter alias again" 
            }

            if($userInput -eq $breakCommandString)
            { break }

            if([string]::IsNullOrEmpty($userInput))
            {  
                $unaliasedItem.IsActive = $false
            }
            else {
                $unaliasedItem.Alias = $userInput
            }
            $updatedActionItems.Add($unaliasedItem)
        }

        $actionItemsStorage.Save()

        #refresh cache
        $cacheStorage = $this.StorageProvider.GetCachedActionItemsStorage()
        $cacheStorage.Update($updatedActionItems.ToArray())
    }

    hidden [bool] ValidateUserInput([string] $userString, [ActionItemType] $itemType)
    {
        if([string]::IsNullOrEmpty($userString) -or $userString -eq [Global]::CommandBreakString)
        { return $true }

        [ActionItemsStorage] $actionItemsStorage = $this.StorageProvider.GetActionItemsStorage()
        $existingActionItem = $actionItemsStorage.GetByAlias($userString, $itemType)
        
        if($existingActionItem -ne $null)
        {
            $this.Logger.LogSimpleText("Entered alias already in use. Existing item details: Name - $($existingActionItem.Name) Type - $($existingActionItem.AIType.ToString()) Path - $($existingActionItem.Path) ")
            return $false
        }

        return $true
    }
}