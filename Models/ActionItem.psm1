using namespace System.Xml
using namespace System.Xml.Serialization

using module .\_BaseActionItem.psm1
using module .\ActionItemType.psm1

class ActionItem : BaseActionItem
{
   [ActionItemType] $AIType
}
Y

[XmlRoot("ActionItemsRoot")]
class ActionItemsContainer
{
    [ActionItem[]] $ActionItems
}