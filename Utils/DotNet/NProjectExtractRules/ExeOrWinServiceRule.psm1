using namespace System.Xml

using module ..\..\..\Models\NetModels.psm1
using module ..\NProjectTypeExtractResult.psm1
using module .\_NProjExtractRule.psm1

class ExeOrWinServiceRule : NProjExtractRule 
{
    hidden [string] $ProjectNodeName = "Project"
    hidden [string] $PropertyGroupNodeName = "PropertyGroup"
    hidden [string] $OutputTypeNodeName = "OutputType"
    hidden [string] $OutputTypeValue = "Exe"
    hidden [string] $StartActionNodeName = "StartAction"
    hidden [string[]] $StartActionValues = @("Program")

    #overridden
    [NProjectTypeExtractResult] Apply([xml] $projectXml, [string] $projectName)
    {
        [NProjectTypeExtractResult] $result = [NProjectTypeExtractResult]::new()
        $result.IsSuccess = $false
        $result.ProjectType = [NProjectType]::ExeOrWinService

        [XmlNode] $rootNode = $projectXml.ChildNodes | Where-Object { $_.LocalName -eq $this.ProjectNodeName } | Select-Object -First 1
        if($rootNode -eq $null)
        { return $result }

        $result.IsSuccess = $this.CheckOutputType($rootNode)

        if($result.IsSuccess -eq $false)
        {
            $result.IsSuccess = $this.CheckStartupAction($rootNode)
        }               

        return $result
    }

    [bool] CheckOutputType([XmlNode] $rootNode)
    {
        [bool] $result = $false
        [XmlNode] $projectGroupNode = $rootNode.ChildNodes | Where-Object { $_.LocalName -eq $this.PropertyGroupNodeName } | Select-Object -First 1
        if($projectGroupNode -eq $null)
        { return $result }


        [XmlNode] $outputNode = $projectGroupNode.ChildNodes | Where-Object { $_.LocalName -eq $this.OutputTypeNodeName } | Select-Object -First 1
        if($outputNode -eq $null)
        { return $result }
                
        $result = $outputNode.InnerText -eq $this.OutputTypeValue
        return $result
    }

    [bool] CheckStartupAction([XmlNode] $rootNode)
    {
        [bool] $result = $false
        $projectGroupNodes = $rootNode.ChildNodes | Where-Object { $_.LocalName -eq $this.PropertyGroupNodeName }
        
        if($projectGroupNodes -eq $null)
        { return $result }

        foreach ($projectGroupNode in $projectGroupNodes) {       
            [XmlNode] $startActionNode = $projectGroupNode.ChildNodes | Where-Object { $_.LocalName -eq $this.StartActionNodeName } | Select-Object -First 1
            
            if($startActionNode -ne $null)
            {
                $result = $this.StartActionValues.Contains($startActionNode.InnerText)
                break
            }
        }

        return $result
    }
}