using module .\CommandsStorage.psm1
using module .\GitReposStorage.psm1
using module .\NetProjectsStorage.psm1
using module ..\Global.psm1
using module ..\Logger.psm1

class StorageProvider
{
    hidden [CommandsStorage] $CommandsStorage
    hidden [GitReposStorage] $GitReposStorage
    hidden [NetProjectsStorage] $NetProjectsStorage

    StorageProvider([Logger] $logger)
    {
        $this.CommandsStorage = [CommandsStorage]::new("$([Global]::RootPath)$([Global]::CommandsPath)", [Logger] $logger)  
        $this.GitReposStorage = [GitReposStorage]::new("$([Global]::RootPath)$([Global]::GitReposPath)", [Logger] $logger)
        $this.NetProjectsStorage = [NetProjectsStorage]::new("$([Global]::RootPath)$([Global]::NetProjectsPath)", [Logger] $logger)
    }

    Reload()
    {
        $this.CommandsStorage.Reload()
        $this.GitReposStorage.Reload()
    }

    [CommandsStorage] GetCommandsStorage()
    {
        return $this.CommandsStorage
    }

    [GitReposStorage] GetGitReposStorage()
    {
        return $this.GitReposStorage
    }
}