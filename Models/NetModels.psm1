using namespace System.Xml.Serialization

[XmlRoot("NetRoot")]
Class NetSolutionsContainer
{
    [NSolution[]] $NetSolutions
}

class NSolution
{
    [string] $Name
    [string] $Alias
    [string] $Path
    [string] $Id
    [NProject[]] $NProjects
}

class NProject
{
    [string] $Name
    [string] $Alias
    [string] $Id   
    [string] $RelativePath
    [Bool] $IsPrimary
    [XmlIgnore()]
    [NSolution] $Solution

    [string] GetFullPath()
    {
       $fullPath = $this.Solution.Path + $this.RelativePath + $this.Name
       return $fullPath
    }

}

