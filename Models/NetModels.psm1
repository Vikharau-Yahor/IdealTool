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
    [NProjectType] $Type
    [Bool] $IsPrimary
    [XmlIgnore()]
    [NSolution] $Solution

    [string] GetFullPath()
    {
       $fullPath = $this.Solution.Path + $this.RelativePath + $this.Name
       return $fullPath
    }

}

enum NProjectType
{
    Dll = 0 # if not in list below 
    Exe = 1 # <Project>.<PropertyGroup>[0].<OutputType>Exe</OutputType> (or WinExe)
    WebApp = 2 # <Project>.<PropertyGroup>[0].<ProjectTypeGuids> is in web type guids (see https://www.codeproject.com/Reference/720512/List-of-Visual-Studio-Project-Type-GUIDs)
    WinService = 3 # <Project>.<PropertyGroup>.<StartAction>Program</StartAction>
}