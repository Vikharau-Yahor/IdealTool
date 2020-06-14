using namespace System.Xml

using module ..\..\..\Models\NetModels.psm1
using module ..\NProjectTypeExtractResult.psm1
using module .\_NProjExtractRule.psm1

class AspNetRule : NProjExtractRule 
{
    hidden [string] $ProjectNodeName = "Project"
    hidden [string] $PropertyGroupNodeName = "PropertyGroup"
    hidden [string] $ProjectTypeGuidsNodeName = "ProjectTypeGuids"
    hidden [string[]] $AspTypeGuids = @(
        "349C5851-65DF-11DA-9384-00065B846F21", 
        "E3E379DF-F4C6-4180-9B81-6769533ABE47",
        "8BB2217D-0F2D-49D1-97BC-3654ED321F3B")

    #overridden
    [NProjectTypeExtractResult] Apply([xml] $projectXml, [string] $projectName)
    {
        [NProjectTypeExtractResult] $result = [NProjectTypeExtractResult]::new()
        $result.IsSuccess = $false
        $result.ProjectType = [NProjectType]::AspNet

        [XmlNode] $rootNode = $projectXml.ChildNodes | Where-Object { $_.LocalName -eq $this.ProjectNodeName } | Select-Object -First 1
        if($rootNode -eq $null)
        { return $result }

        foreach($node in $rootNode.ChildNodes)
        {
            [XmlNode] $childNode = $node
            if ($childNode.LocalName -eq $this.PropertyGroupNodeName)
            {
                [XmlNode] $guidsNode = $childNode.ChildNodes | Where-Object { $_.LocalName -eq $this.ProjectTypeGuidsNodeName } | Select-Object -First 1

                if($guidsNode -eq $null)
                { break }
                
                $result.IsSuccess = $this.IsAnyAspGuid($guidsNode.InnerText)
                
                #exit loop
                break
            }
        }

        return $result
    }

    hidden [Bool] IsAnyAspGuid([string] $projectTypGuidsString)
    {
        [Bool] $isSuccess = $false

        if([string]::IsNullOrEmpty($projectTypGuidsString))
        { return $isSuccess }

        foreach($guid in $this.AspTypeGuids)
        {
            $isSuccess = ($projectTypGuidsString.IndexOf($guid, [System.StringComparison]::InvariantCultureIgnoreCase) -ne -1)
            
            if($isSuccess)
            { break }
        }

        return $isSuccess
    }
}