using module ..\..\Models\EntityType.psm1
using module .\CommonHelper.psm1

class EntityHelper
{

    static [string] GenerateId([EntityType] $entityType, [string] $entityName, [string] $entityPath)
    {
        [CH]::ThrowError($entityType -eq $null, "EntityHelper.GenerateId: EntityType cannot be empty")
        [CH]::ThrowError([string]::IsNullOrEmpty($entityName), "EntityHelper.GenerateId: EntityName cannot be empty")
        [CH]::ThrowError([string]::IsNullOrEmpty($entityPath), "EntityHelper.GenerateId: EntityPath cannot be empty")

        $entityPathHash = $entityPath.GetHashCode()
        [string] $globalId = "$($entityType.ToString())#$entityName-$entityPathHash"
        return $globalId
    }
}