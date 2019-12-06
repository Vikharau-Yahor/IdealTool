using module .\Modules\CommandHandlers.psm1
using module .\Configs\CommandsStorage.psm1
using namespace System.Collections.Generic

class Main
{
    static [string] $RootPath
    # configs
    static [string] $MainCfgPath = "\Main.cfg"
    static [string] $CommandsCfgPath = "\Configs\Commands.cfg"
    static [string] $ManagedScriptsPath = "\Scripts\Managed"
    static [string] $UnManagedScriptsPath = "\Scripts\UnManaged"

    [CommandsStorage] $CommandsStorage

    Init($scriptRootPath)
    {
        [Main]::RootPath = $scriptRootPath
        $this.CommandsStorage = [CommandsStorage]::new("$([Main]::RootPath)$([Main]::CommandsCfgPath)")      
    }


    Start()
    {
        $userInput = ""
        $quitComAlias = $this.CommandsStorage.GetAlias([CommandsEnum]::Quit)
        while($userInput -ne $quitComAlias)
        {
            $userInput = Read-Host "($quitComAlias to exit) command"
            Write-Host ($this.ProcessCommand($userInput) + "`n")           
        }
    }


    [string] ProcessCommand([string] $commandStr)
    {
        if($commandStr -eq $this.CommandsStorage.GetAlias([CommandsEnum]::Quit))
        {  
            return ""
        }

        $commandParts = $this.SplitOnCommandAndParams($commandStr)
        $commandAlias = $commandParts.Item1
        $commandParams = $commandParts.Item2

        [Command]$command = $this.CommandsStorage.GetByAlias($commandAlias)
        if($command -eq $null)
        {
            Write-Host "Unknown command: $commandAlias"
            return ""
        }

        switch($command.Id)
        {
            ([CommandsEnum]::UnmanagedRun) { Write-Host ([ComHandlers]::URunHandle("$([Main]::RootPath)\$([Main]::UnManagedScriptsPath)", $commandParams)) }
            default { Write-Host "There is no handler for command: $($command.Id)" }
        }

        return ""
    }

    [System.Tuple[string,string]] SplitOnCommandAndParams($commandString)
    {
        $commandDelimiterIndex = $commandString.IndexOf(' ');
        if($commandDelimiterIndex -eq -1)
        {
            return [System.Tuple[string,string]]::new($commandString, [string]::Empty)
        }

        $command =  $commandString.Substring(0, $commandDelimiterIndex)
        $params = $commandString.Substring($commandDelimiterIndex + 1, $commandString.Length - $commandDelimiterIndex - 1)

        return [System.Tuple[string,string]]::new($command, $params)
    }

}

# main
$main = New-Object Main
$main.Init($PSScriptRoot)
$main.Start()



class CommandHanldersFactory
{
    [CommandHandlerBase] Create([CommandsEnum] $commandType)
    {
        [CommandHandlerBase] $handler = $null
        switch($commandType)
        {
            ([CommandsEnum]::UnmanagedRun) { $handler = [URunHandler]::new() } 
            default { return $null }
        }

        return $handler;
    }
}


class CommandHandlerBase
{
    #singletone
    [Object] $configManager
    [string] $commandParamsString

    CommandHandlerBase($configManager, $commandParamsString)
    {
        $this.configManager = $configManager
        $this.commandParamsString = $commandParamsString
    }

    #returnInfoMessage
    [string]Handle()
    { 
        return ''
    }
}

class URunHandler : CommandHandlerBase
{
    #override
    [string]Handle()
    { 
        return ''
    }
}