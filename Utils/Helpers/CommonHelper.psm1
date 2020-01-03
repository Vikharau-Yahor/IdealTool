class CH
{
    # c# ternary operator: 
    # $condition ? $trueResult : $falseResult
    static [Object] Ternary([bool] $condition, [Object] $trueResult, [Object] $falseResult)
    {
        if($condition) { 
            return $trueResult 
        } 
        else 
        { 
            return $falseResult
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