using namespace System.Collections.Generic

using module ..\Models\Command.psm1
using module ..\Models\CommandsEnum.psm1
using module ..\Models\CommandModifier.psm1
using module ..\Utils\Helpers\XmlHelper.psm1
using module ..\Logger.psm1

class CommandsStorage
{ 
    [Dictionary[string, Command]] $CommandsByAlias
    [Dictionary[CommandsEnum, Command]] $CommandsById
    [string] $ConfigFullPath
    [Logger] $Logger

    CommandsStorage([string]$cfgPath, [Logger] $logger)
    {
        $this.ConfigFullPath = $cfgPath
        $this.Logger = $logger
        $this.Reload()
    }
    
    Reload()
    {
        $this.CommandsByAlias = [Dictionary[string, Command]]::new()
        $this.CommandsById = [Dictionary[CommandsEnum, Command]]::new()
               
        [CommandsContainer]$commandsContainer = [XmlHelper]::Deserialize([CommandsContainer], $this.ConfigFullPath)
        $commandsContainer.Commands | ForEach-Object {
            $command = $_
            $this.CommandsByAlias.Add($command.Alias,$command)  
            $this.CommandsById.Add($command.Id,$command)   
        }    
    }

    [Command] GetByAlias([string] $commAlias)
    {
        if($this.CommandsByAlias.ContainsKey($commAlias))
        {
            return $this.CommandsByAlias[$commAlias] 
        }
        else
        {
            return $null
        }
    }

    [string] GetAlias([CommandsEnum] $commandId)
    {
        if($this.CommandsById.ContainsKey($commandId))
        {
            return $this.CommandsById[$commandId].Alias 
        }
        else
        {
            return $null
        }
    }

    [CommandModifier[]] GetCommandModifiers([CommandsEnum] $commandId)
    {
        if($this.CommandsById.ContainsKey($commandId))
        {
            return $this.CommandsById[$commandId].Modifiers 
        }
        else
        {
            return @()
        }
    }
}
