using namespace System.Collections.Generic
using namespace System.Xml

using module ..\Models\CommandsEnum.psm1
using module ..\Models\Command.psm1
using module ..\Utils\XmlHelper.psm1

class CommandsStorage
{ 
    #object props
    [Dictionary[string, Command]] $CommandsByAlias
    [Dictionary[CommandsEnum, Command]] $CommandsById
    [string] $ConfigFullPath

    CommandsStorage([string]$cfgPath)
    {
        $this.ConfigFullPath = $cfgPath
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
        return     
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
}
