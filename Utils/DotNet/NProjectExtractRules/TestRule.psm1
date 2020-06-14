using namespace System.Xml

using module ..\..\..\Models\NetModels.psm1
using module ..\NProjectTypeExtractResult.psm1
using module .\_NProjExtractRule.psm1

class TestRule : NProjExtractRule 
{
    hidden [string[]] $TestProjectNameMarkers = @(".Tests.", ".Test.")

    #overridden
    [NProjectTypeExtractResult] Apply([xml] $projectXml, [string] $projectName)
    {
        [NProjectTypeExtractResult] $result = [NProjectTypeExtractResult]::new()
        $result.IsSuccess = $false
        $result.ProjectType = [NProjectType]::Test

        foreach($marker in $this.TestProjectNameMarkers)
        {
            $result.IsSuccess = ($projectName.IndexOf($marker, [System.StringComparison]::InvariantCultureIgnoreCase) -ne -1)
            
            if($result.IsSuccess)
            { break }
        }

        return $result
    }
}