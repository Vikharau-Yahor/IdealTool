using namespace System.Xml.Serialization

using module .\_BaseActionItem.psm1

Class GitRepo : BaseActionItem
{
    [string] $Url
}

[XmlRoot("GitRoot")]
Class GitReposContainer
{
    [GitRepo[]] $GitRepositories
}