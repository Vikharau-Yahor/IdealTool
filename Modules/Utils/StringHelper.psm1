using namespace System.Text.RegularExpressions

class StringHelper
{
    static [bool] StringIsMatchedToRegExp([string]$string, [string]$regExp)
    {
        if([string]::IsNullOrEmpty($string) -or [string]::IsNullOrEmpty($regExp)) 
        { return $false }

        [Regex] $regexObj = [Regex]::new($regExp)
    
        return $regexObj.IsMatch($string)
    }
}