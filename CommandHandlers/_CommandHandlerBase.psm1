using module ..\Storages\_StorageProvider.psm1
using module ..\Logger.psm1

class CommandHandlerBase
{
    [Logger] $Logger
    [StorageProvider] $StorageProvider
    [string] $CommandParams

    CommandHandlerBase([StorageProvider]$storageProvider, [Logger] $logger, [string]$commandParams)
    {
        $this.StorageProvider = $storageProvider
        $this.Logger = $logger
        $this.CommandParams = $commandParams
    }

    [void] Handle()
    { 
        throw "Handle() must be implemented in inherited class"
    }
}