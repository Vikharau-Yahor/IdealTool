using namespace System.Collections.Generic
using namespace System.Xml

enum CommandsEnum
{
    Quit = 0
    Scan = 1
    Run = 2
    UnmanagedRun = 3
    OpenVisualStudio = 4
    OpenRider = 5
}


class CommandsStorage
{ 
    #config xPathes
    [string] $xRoot = "/Commands"
    [string] $xCommandIdAttr = "Id"

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
        $configXml = [XmlDocument]::new()
        $configXml.Load($this.ConfigFullPath)
        
        if($configXml -eq $null)
        {
            throw [System.IO.FileNotFoundException] "Config file is null"
        }

        [XmlNode]$rootNode = $configXml.SelectSingleNode($this.xRoot)

        $rootNode.ChildNodes | ForEach-Object {
            [XmlNode]$node = $_ 
            $command = [Command]::new()
            $idValue = $node.Attributes.GetNamedItem($this.xCommandIdAttr).Value
            $command.Id = [int]::Parse($idValue)
            $command.Alias = $node.InnerText      
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
}


class Command
{
    [CommandsEnum] $Id 
    [string] $Alias
}