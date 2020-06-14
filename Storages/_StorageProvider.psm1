using module .\CommandsStorage.psm1
using module .\GitReposStorage.psm1
using module .\NetProjectsStorage.psm1
using module .\EntitiesStorage.psm1
using module ..\Global.psm1
using module ..\Logger.psm1

class StorageProvider
{
    hidden [CommandsStorage] $CommandsStorage
    hidden [GitReposStorage] $GitReposStorage
    hidden [NetProjectsStorage] $NetProjectsStorage
    hidden [EntitiesStorage] $EntitiesStorage

    StorageProvider([Logger] $logger)
    {
        $this.CommandsStorage = [CommandsStorage]::new("$([Global]::RootPath)$([Global]::CommandsPath)", [Logger] $logger)  
        $this.GitReposStorage = [GitReposStorage]::new("$([Global]::RootPath)$([Global]::GitReposPath)", [Logger] $logger)
        $this.NetProjectsStorage = [NetProjectsStorage]::new("$([Global]::RootPath)$([Global]::NetProjectsPath)", [Logger] $logger)
        $this.EntitiesStorage = [EntitiesStorage]::new("$([Global]::RootPath)$([Global]::EntitiesPath)", [Logger] $logger)
    }

    Reload()
    {
        $this.CommandsStorage.Reload()
        $this.GitReposStorage.Reload()
        $this.NetProjectsStorage.Reload()
        $this.EntitiesStorage.Reload()
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

    [EntitiesStorage] GetEntitiesStorage()
    {
        return $this.EntitiesStorage
    }
}