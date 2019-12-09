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