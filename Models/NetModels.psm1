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
    ExeOrWinService = 1 # <Project>.<PropertyGroup>[0].<OutputType>Exe</OutputType> (or WinExe)
    AspNet = 2 # <Project>.<PropertyGroup>[0].<ProjectTypeGuids> is in web type guids (see https://www.codeproject.com/Reference/720512/List-of-Visual-Studio-Project-Type-GUIDs)
    WinService = 3 # possible not used because it's considered as Exe
    Test = 4 # check project name
}