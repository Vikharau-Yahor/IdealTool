using module .\CommandsStorage.psm1
using module .\GitReposStorage.psm1
using module .\NetProjectsStorage.psm1
using module .\ActionItemsStorage.psm1
using module ..\Global.psm1
using module ..\Logger.psm1

class StorageProvider
{
    hidden [CommandsStorage] $CommandsStorage
    hidden [GitReposStorage] $GitReposStorage
    hidden [NetProjectsStorage] $NetProjectsStorage
    hidden [ActionItemsStorage] $ActionItemsStorage

    StorageProvider([Logger] $logger)
    {
        $this.ActionItemsStorage = [ActionItemsStorage]::new("$([Global]::RootPath)$([Global]::ActionItemsPath)", [Logger] $logger)
        $this.CommandsStorage = [CommandsStorage]::new("$([Global]::RootPath)$([Global]::CommandsPath)", [Logger] $logger)  
        $this.GitReposStorage = [GitReposStorage]::new("$([Global]::RootPath)$([Global]::GitReposPath)", $this.ActionItemsStorage, [Logger] $logger)
        $this.NetProjectsStorage = [NetProjectsStorage]::new("$([Global]::RootPath)$([Global]::NetProjectsPath)", $this.ActionItemsStorage, [Logger] $logger)
    }

    Reload()
    {
        $this.CommandsStorage.Reload()
        $this.GitReposStorage.Reload()
        $this.NetProjectsStorage.Reload()
        $this.ActionItemsStorage.Reload()
    }

    [CommandsStorage] GetCommandsStorage()
    {
        return $this.CommandsStorage
    }

    [GitReposStorage] GetGitReposStorage()
    {
        return $this.GitReposStorage
    }

    [NetProjectsStorage] GetNetProjectsStorage()
    {
        return $this.NetProjectsStorage
    }

    [ActionItemsStorage] GetActionItemsStorage()
    {
        return $this.ActionItemsStorage
    }
}