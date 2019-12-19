using module .\Storages\_StorageProvider.psm1
using module .\Models\CommandsEnum.psm1
using module .\Models\Command.psm1
using module .\CommandHandlersFactory.psm1
using module .\CommandHandlers\_CommandHandlerBase.psm1
using module .\Global.psm1
using module .\Logger.psm1

using namespace System.Collections.Generic

class Main
{
    [StorageProvider] $StorageProvider
    [CommandHanldersFactory] $ComHandlersFactory
    [Logger] $Logger

    Init($scriptRootPath)
    {
        [Global]::RootPath = $scriptRootPath
        $this.Logger = [Logger]::new()   
        $this.StorageProvider = [StorageProvider]::new($this.Logger)   
        $this.ComHandlersFactory = [CommandHanldersFactory]::new($this.StorageProvider, $this.Logger)   
    }


    Start()
    {
        $userInput = ""
        $quitComAlias = $this.StorageProvider.GetCommandsStorage().GetAlias([CommandsEnum]::Quit)
       
        while($userInput -ne $quitComAlias)
        {
            Write-Host ''
            $userInput = Read-Host "($quitComAlias to exit) command"     
            $this.ProcessCommand($userInput)     
        }
    }

    [void] ProcessCommand([string] $commandStr)
    {
        $commandStorage = $this.StorageProvider.GetCommandsStorage()
        
        if($commandStr -eq $commandStorage.GetAlias([CommandsEnum]::Quit))
        { return }

        $commandItems = $this.ExtractCommandNameAndParams($commandStr)
        $commandAlias = $commandItems.Item1.Trim()
        $commandParams = $commandItems.Item2.Trim()

        [Command]$command = $commandStorage.GetByAlias($commandAlias)
        if($command -eq $null)
        {
            $this.Logger.LogInfo("Unknown command: $commandAlias")
            return
        }

        [CommandHandlerBase]$handler = $this.ComHandlersFactory.Create($command.Id, $commandParams)
       
        if($handler -eq $null)
        {
            $this.Logger("There is no handler for command: $($command.Id)")
            return
        }

        $handler.Handle()
    }

    [System.Tuple[string,string]] ExtractCommandNameAndParams($commandString)
    {
        $commandString = $commandString.Trim()
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
$ErrorActionPreference = [Global]::ErrorPreferenceOption
$main = New-Object Main
$main.Init($PSScriptRoot)
$main.Start()
