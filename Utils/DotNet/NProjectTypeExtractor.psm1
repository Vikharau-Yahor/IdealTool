using namespace System.Xml

using module ..\..\Models\NetModels.psm1
using module ..\Helpers\CommonHelper.psm1
using module .\NProjectTypeExtractResult.psm1

#rules
using module .\NProjectExtractRules\_NProjExtractRule.psm1
using module .\NProjectExtractRules\AspNetRule.psm1
using module .\NProjectExtractRules\ExeOrWinServiceRule.psm1 
using module .\NProjectExtractRules\TestRule.psm1 


class NProjectTypeExtractor
{
    [NProjExtractRule[]] $rules
   
    NProjectTypeExtractor()
    {
        $this.rules = @([TestRule]::new(), [ExeOrWinServiceRule]::new(), [AspNetRule]::new())
    }

    [NProjectType] ExtractType([string] $csprojPath)
    {
        [CH]::ThrowError($csprojPath -eq $null, "NProjectTypeExtractor.GetType: csprojPath cannot be empty")
        [NProjectType] $extractedType = [NProjectType]::Dll

        [XmlDocument] $projectXml =  [XmlDocument]::new();
        $projectXml.Load($csprojPath)
        [string] $projectName = $csprojPath | Split-Path -Leaf

        foreach($rule in $this.rules)
        {
            [NProjectTypeExtractResult] $result = $rule.Apply($projectXml, $projectName)
            if($result.IsSuccess)
            {
                $extractedType = $result.ProjectType
                break
            }
        }

        return $extractedType
    }
}