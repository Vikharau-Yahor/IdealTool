using namespace System.Xml

using module ..\..\..\Models\NetModels.psm1
using module ..\NProjectTypeExtractResult.psm1

class NProjExtractRule
{
   [NProjectTypeExtractResult] Apply([xml] $projectXml, [string] $projectName)
   {
      throw "BaseNProjExtractRule.Apply() must be implemented in inherited class"
   }
}