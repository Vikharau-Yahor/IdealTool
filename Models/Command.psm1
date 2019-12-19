using namespace System.Xml
using namespace System.Xml.Serialization

using module .\CommandsEnum.psm1

class Command
{
    [CommandsEnum] $Id 
    [string] $Alias
}

[XmlRoot("CommandsRoot")]
class CommandsContainer
{
    [Command[]] $Commands
}