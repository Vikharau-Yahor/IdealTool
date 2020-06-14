using namespace System.Xml
using namespace System.Xml.Serialization

using module .\_BaseActionItem.psm1
using module .\ActionItemType.psm1

# Represent all known items which are consumed by commandHandlers (git repos, net solutions and etc)
class ActionItem : BaseActionItem
{
    ActionItem()
    {

    }

    ActionItem([BaseActionItem] $baseInfo, [ActionItemType] $actionItemType) {
        $this.Id = $baseInfo.Id
        $this.IsActive = $baseInfo.IsActive
        $this.Name = $baseInfo.Name
        $this.Path = $baseInfo.Path
        $this.Alias = $baseInfo.Alias
        $this.AIType = $actionItemType
    }

   [ActionItemType] $AIType
}


[XmlRoot("ActionItemsRoot")]
class ActionItemsContainer
{
    [ActionItem[]] $ActionItems
}