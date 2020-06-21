using namespace System.Xml.Serialization

using module .\_BaseActionItem.psm1
using module .\ActionItem.psm1

Class GitRepo : BaseActionItem
{
    #private
    [XmlIgnore()]
    hidden [ActionItem] $BasicData

    #public
    [string] $Url

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

[XmlRoot("GitRoot")]
Class GitReposContainer
{
    [GitRepo[]] $GitRepositories
}