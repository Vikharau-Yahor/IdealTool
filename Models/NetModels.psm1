using namespace System.Xml.Serialization

[XmlRoot("NetRoot")]
Class NetSolutionsContainer
{
    [NSolution[]] $NetSolutions
}

class NSolution
{
    [string] $Id
    [string] $Alias
    [string] $Name
    [string] $Path
    [Bool] $IsPrimary
}

class NProject
{
    [string] $Id
    [string] $Alias
    [string] $Name
    [string] $RelativePath
    [Bool] $IsPrimary
    [NSolution] $Solution

    [string] GetFullPath()
    {
       $fullPath = $this.Solution.Path + $this.RelativePath + $this.Name
       return $fullPath
    }

}

