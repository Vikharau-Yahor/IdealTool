using namespace System.Collections
using namespace System.Collections.Generic

using module .\CommandsStorage.psm1
using module .\GitReposStorage.psm1
using module .\NetProjectsStorage.psm1
using module .\ActionItemsStorage.psm1
using module .\CachedActionItemsStorage.psm1
using module .\_AbstractActionItemsStorage.psm1

using module ..\Models\ActionItemType.psm1
using module ..\Global.psm1
using module ..\Logger.psm1

class StorageProvider
{
    hidden [CommandsStorage] $CommandsStorage
    hidden [GitReposStorage] $GitReposStorage
    hidden [NetProjectsStorage] $NetProjectsStorage
    hidden [ActionItemsStorage] $ActionItemsStorage
    hidden [CachedActionItemsStorage] $CachedActionItemsStorage

    hidden [Dictionary[ActionItemType, AbstractActionItemsStorage]] $ItemsStorages
    
    StorageProvider([Logger] $logger)
    {
        $this.ActionItemsStorage = [ActionItemsStorage]::new("$([Global]::RootPath)$([Global]::ActionItemsPath)", [Logger] $logger)
        $this.CachedActionItemsStorage = [CachedActionItemsStorage]::new("$([Global]::RootPath)$([Global]::CachedActionItemsPath)", [Logger] $logger)
        $this.CommandsStorage = [CommandsStorage]::new("$([Global]::RootPath)$([Global]::CommandsPath)", [Logger] $logger)  
        $this.GitReposStorage = [GitReposStorage]::new("$([Global]::RootPath)$([Global]::GitReposPath)", $this.ActionItemsStorage, $this.CachedActionItemsStorage, [Logger] $logger)
        $this.NetProjectsStorage = [NetProjectsStorage]::new("$([Global]::RootPath)$([Global]::NetProjectsPath)", $this.ActionItemsStorage, $this.CachedActionItemsStorage, [Logger] $logger)
        
        $this.ItemsStorages = [Dictionary[ActionItemType, AbstractActionItemsStorage]]::new()
        $this.ItemsStorages.Add([ActionItemType]::Git, $this.GitReposStorage)
        $this.ItemsStorages.Add([ActionItemType]::NProj, $this.NetProjectsStorage)
        
    }

    Reload()
    {
        $this.CommandsStorage.Reload()
        # actionItemsStorage must be first
        $this.ActionItemsStorage.Reload()
        $this.GitReposStorage.Reload()
        $this.NetProjectsStorage.Reload()
        $this.CachedActionItemsStorage.Restore()
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

    [CachedActionItemsStorage] GetCachedActionItemsStorage()
    {
        return $this.CachedActionItemsStorage
    }

    #unused??
    [Dictionary[ActionItemType, AbstractActionItemsStorage]] GetItemsStoragesDictionary()
    {
        return $this.ItemsStorages
    }
}