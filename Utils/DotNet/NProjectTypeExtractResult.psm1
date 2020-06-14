using namespace System.Xml

using module ..\..\Models\NetModels.psm1

class NProjectTypeExtractResult
{
    [bool] $IsSuccess
    [NProjectType] $ProjectType
}