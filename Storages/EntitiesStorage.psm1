using namespace System.Linq
using namespace System.Collections.Generic

using module ..\Models\Entity.psm1
using module ..\Utils\Helpers\XmlHelper.psm1
using module ..\Logger.psm1

class EntitiesStorage
{ 
    [string] $ConfigFullPath
    [Entity[]] $Entities
    [Logger] $Logger

    EntitiesStorage([string]$cfgPath, [Logger] $logger)
    {
        $this.ConfigFullPath = $cfgPath
        $this.Logger = $logger
        $this.Reload()
    }

    Reload()
    {
        $this.Entities = @()

        if(-not (Test-Path -Path $this.ConfigFullPath))
        { return }
               
        try
        {
            [EntitiesContainer]$entitiesContainer = [XmlHelper]::Deserialize([EntitiesContainer], $this.ConfigFullPath)
            
            if( $null -eq $entitiesContainer -or $null -eq $entitiesContainer.Entities)
            { return }

            $this.Entities = $entitiesContainer.Entities
        }
        catch [System.Exception]
        {
            $this.Logger.LogError("Entities deserialization has been failed from file: $($this.ConfigFullPath). Exception:$($_.Exception)")         
        }
    }

    Save()
    {
        [EntitiesContainer] $entitiesContainer = [EntitiesContainer]::new()
        $entitiesContainer.Entities = $this.Entities

        [XmlHelper]::Serialize($entitiesContainer, $this.ConfigFullPath)
        $this.Logger.LogInfo("New entities have been saved to file: $($this.ConfigFullPath)")
    }

    Save([Entity[]] $entities)
    {  
        if($null -eq $entities -or $entities.Length -eq 0)
        {  return; }

        [List[string]] $currentEntitiesKeys = @() 
        $this.Entities | ForEach-Object { $currentEntitiesKeys.Add($_.Id) }

        [List[Entity]] $newEntities = @()
        $newEntities = $entities | Where-Object { $currentEntitiesKeys -eq $null -or (-not $currentEntitiesKeys.Contains($_.Id)) }
        $this.Logger.LogInfo("New entities to be saved: $($newEntities.Count)")
        
        if( $newEntities.Count -eq 0)
        { return; }
        
        $newEntities.AddRange($this.Entities)
        $this.Entities = $newEntities | Sort-Object -Property Name
        $this.Save()
    }

    [Entity[]] GetNonAliasedEntities()
    {
        [Entity[]] $result = $this.Entities | Where-Object { [string]::IsNullOrEmpty($_.Alias) }
        return $result
    }
}