using namespace System.Xml.Serialization

Class GitRepo
{
    [string] $Name
    [string] $Alias
    [string] $Url
    [string] $Path
    [string] $Id
}

[XmlRoot("GitRoot")]
Class GitReposContainer
{
    [GitRepo[]] $GitRepositories
}