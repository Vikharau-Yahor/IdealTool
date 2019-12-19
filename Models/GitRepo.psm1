using namespace System.Xml.Serialization

Class GitRepo
{
    [string] $Id
    [string] $Alias
    [string] $Name
    [string] $Url
    [string] $Path
}

[XmlRoot("GitRoot")]
Class GitReposContainer
{
    [GitRepo[]] $GitRepositories
}