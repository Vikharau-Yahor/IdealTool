using module .\CommandsStorage.psm1
using module ..\Global.psm1

class StorageProvider
{
    [CommandsStorage] $CommandsStorage;

    StorageProvider()
    {
        $this.CommandsStorage = [CommandsStorage]::new("$([Global]::RootPath)$([Global]::CommandsPath)")  
    }

    Reload()
    {
        $this.CommandsStorage.Reload()
    }

    [CommandsStorage] GetCommandsStorage()
    {
        return $this.CommandsStorage
    }

}