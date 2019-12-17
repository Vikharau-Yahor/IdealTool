
class CH
{
    # c# ternary operator: 
    # $condition ? $ternaryTrueResult : $ternaryFalseResult
    static [Object] Ternary([bool] $condition, [Object] $ternaryTrueResult, [Object] $ternaryFalseResult)
    {
        if($condition) { 
            return $ternaryTrueResult 
        } 
        else 
        { 
            return $ternaryFalseResult
        }
    }

    # c# Null coalescing operator: 
    # $targetObj ?? $onNullResult
    static [Object] NullCoalesce($targetObj, $onNullResult)
    {
        if($targetObj -eq $null)
        {
            return $onNullResult
        }
        else
        {
            return $targetObj
        }
    }

    static [void] ThrowError([bool] $errorThrowingCondition, [string] $errorMessage)
    {
        if($errorThrowingCondition)
        { 
            throw $errorMessage 
        }
    }
}