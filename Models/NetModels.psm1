using namespace System.Xml.Serialization

using module .\_BaseActionItem.psm1

[XmlRoot("NetRoot")]
Class NetSolutionsContainer
{
    [NSolution[]] $NetSolutions
}

class NSolution : BaseActionItem
{
    [NProject[]] $NProjects
}

class NProject : BaseActionItem
{   
    [string] $RelativePath
    [NProjectType] $Type

    [XmlIgnore()]
    [NSolution] $Solution

    [string] GetFullPath()
    {
       $fullPath = $this.Path
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