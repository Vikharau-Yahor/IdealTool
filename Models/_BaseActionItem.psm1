using namespace System.Xml
using namespace System.Xml.Serialization

# base class for all action items (git repos, solutions and etc)
class BaseActionItem
{
    [string] $Id 
    [string] $Alias
    [String] $Name
    [string] $Path

    #inactive items are ignored in all tool commands
    [bool] $IsActive
}
