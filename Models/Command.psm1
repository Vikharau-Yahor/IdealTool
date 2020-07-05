using namespace System.Xml
using namespace System.Xml.Serialization

using module .\CommandsEnum.psm1
using module .\CommandModifier.psm1
using module .\CommandModifiersEnum.psm1

class Command
{
    [CommandsEnum] $Id 
    [string] $Alias
    [string] $Help
    [CommandModifier[]] $Modifiers
}

[XmlRoot("CommandsRoot")]
class CommandsContainer
{
    [Command[]] $Commands
}