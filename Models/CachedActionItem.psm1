using namespace System.Xml
using namespace System.Xml.Serialization

using module .\ActionItemType.psm1


class CachedActionItem
{
    # cache identifiers
    [string] $Id 
    [String] $Name
    [ActionItemType] $AIType

    #cached action items fields
    [string] $CachedAlias
    [bool] $CachedIsActive
}

[XmlRoot("CachedActionItemsRoot")]
class CachedActionItemsContainer
{
    [CachedActionItem[]] $CachedActionItems
}