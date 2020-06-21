using namespace System.Xml
using namespace System.Xml.Serialization

using module .\_BaseActionItem.psm1
using module .\ActionItemType.psm1
using module ..\Utils\Helpers\ActionItemHelper.psm1

# Generic info about all known items (git repos, net solutions and etc)
class ActionItem : BaseActionItem
{
    [string] $Alias
    [String] $Name
    [string] $Path
    #inactive items are ignored in all tool commands
    [bool] $IsActive
    [ActionItemType] $AIType

    ActionItem()
    {

    }

    ActionItem([string] $name, [string] $path, [bool] $isActive, [ActionItemType] $actionItemType) {
        $this.Id = [ActionItemHelper]::GenerateId($actionItemType, $name, $path)
        $this.Name = $name
        $this.Path = $path
        $this.IsActive = $isActive
        $this.AIType = $actionItemType
    }
}


[XmlRoot("ActionItemsRoot")]
class ActionItemsContainer
{
    [ActionItem[]] $ActionItems
}