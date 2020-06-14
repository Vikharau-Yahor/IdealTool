using module ..\..\Models\ActionItemType.psm1
using module .\CommonHelper.psm1

class ActionItemHelper
{
    static [string] GenerateId([ActionItemType] $actionItemType, [string] $actionItemName, [string] $actionItemPath)
    {
        [CH]::ThrowError($actionItemType -eq $null, "ActionItemHelper.GenerateId: actionItemType cannot be empty")
        [CH]::ThrowError([string]::IsNullOrEmpty($actionItemName), "ActionItemHelper.GenerateId: actionItemName cannot be empty")
        [CH]::ThrowError([string]::IsNullOrEmpty($actionItemPath), "ActionItemHelper.GenerateId: actionItemPath cannot be empty")

        $actionItemPathHash = $actionItemPath.GetHashCode()
        [string] $generatedId = "$($actionItemType.ToString())#$actionItemName#$actionItemPathHash"
        return $generatedId
    }
}