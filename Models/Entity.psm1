using namespace System.Xml
using namespace System.Xml.Serialization

using module .\EntityType.psm1

class Entity
{
    [string] $Id 
    [string] $Alias
    [String] $Name
}

class EntityInfo : Entity
{
    [EntityType] $Type
}

[XmlRoot("Entities")]
class EntitiesContainer
{
    [Entity[]] $Entities
}