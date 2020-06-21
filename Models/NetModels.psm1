using namespace System.Xml.Serialization
using namespace System.Collections.Generic

using module .\_BaseActionItem.psm1
using module .\ActionItem.psm1

[XmlRoot("NetRoot")]
Class DotNetItemsContainer
{
    [NSolution[]] $NetSolutions
    [NProject[]] $NetProjects
}

class NSolution : BaseActionItem
{
    #private
    [XmlIgnore()]
    hidden [ActionItem] $BasicData

    #public
    [string[]] $ProjectsIds

    SetInitialBasicData([ActionItem] $basicData)
    {
        if($this.BasicData -eq $null)
        {
            $this.BasicData = $basicData
        }
        $this.Id = $basicData.Id
    }

    [ActionItem] GetBaseData()
    {
        return $this.BasicData
    }
}

class NProject : BaseActionItem
{   
    #private
    [XmlIgnore()]
    hidden [ActionItem] $BasicData
    
    #public
    [NProjectType] $Type
    [string[]] $SolutionsIds

    [bool] IsPrimary()
    {
        $isPrimary = ($this.Type -ne [NProjectType]::Dll) -and ($this.Type -ne [NProjectType]::Test)
        return $isPrimary
    }

    SetInitialBasicData([ActionItem] $basicData)
    {
        if($this.BasicData -eq $null)
        {
            $this.BasicData = $basicData
        }
        $this.Id = $basicData.Id
    }

    [ActionItem] GetBaseData()
    {
        return $this.BasicData
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