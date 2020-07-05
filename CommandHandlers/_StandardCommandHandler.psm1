using namespace System.Collections.Generic

using module .\_CommandHandlerBase.psm1
using module ..\Storages\_StorageProvider.psm1
using module ..\Models\CommandModifiersEnum.psm1
using module ..\Models\CommandsEnum.psm1
using module ..\Models\CommandModifier.psm1
using module ..\Logger.psm1

# inherit it if your handler works with aliases and modifiers
class StandardCommandHandler : CommandHandlerBase
{
    [string[]] $Aliases = @()
    [CommandModifiersEnum[]] $ActiveModifiers = @()

    StandardCommandHandler ([StorageProvider]$storageProvider, [Logger] $logger, [string]$commandParams, [CommandsEnum] $commandType) : base($storageProvider, $logger, $commandParams)
    { 
        $this.SetupAliasesAndModifiers([CommandsEnum] $commandType)
    }

    SetupAliasesAndModifiers([CommandsEnum] $commandType)
    {
       $params = $this.ExtractParams($this.CommandParams)
       if($params.Count -eq 0)
       { return }

       [List[string]] $aliasesList = [List[string]]::new()
       [List[CommandModifiersEnum]] $matchedModifiers = [List[CommandModifiersEnum]]::new()
      
       [CommandModifier[]] $commandModifiers = $this.StorageProvider.GetCommandsStorage().GetCommandModifiers($commandType)
       if($commandModifiers -eq $null -or $commandModifiers.Count -eq 0)
       {
           $this.Aliases = $params
           return
       }

       foreach($param in $params)
       {
            if (-not $param.StartsWith("-"))
            {
                $aliasesList.Add($param)
            }
            else
            {
                if ($param.Length -eq 1)
                { continue }

                $enteredModifier = $param.Substring(1, ($param.Length - 1)).ToLower()
                $matchedModifier = $commandModifiers | Where-Object { ($_.Alias.ToLower()) -eq $enteredModifier }
                
                if($matchedModifier -ne $null)
                { $matchedModifiers.Add($matchedModifier.Id) }
                else {
                    $this.Logger.LogInfo("Unknown modifier has been entered: '$param'")
                }
            }
       }
       $this.Aliases = $aliasesList.ToArray()
       $this.ActiveModifiers = $matchedModifiers.ToArray()
    }
}