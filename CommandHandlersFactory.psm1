using module .\Models\CommandsEnum.psm1
using module .\Storages\_StorageProvider.psm1
using module .\Logger.psm1
#Command handlers
using module .\CommandHandlers\_CommandHandlerBase.psm1
using module .\CommandHandlers\URunScriptHandler.psm1
using module .\CommandHandlers\ScanHandler.psm1
using module .\CommandHandlers\SetAliasHandler.psm1
using module .\CommandHandlers\OpenVS.psm1
using module .\CommandHandlers\RunExe.psm1

class CommandHanldersFactory
{
    [StorageProvider] $StorageProvider
    [Logger] $Logger

    CommandHanldersFactory([StorageProvider] $storageProvider, [Logger] $logger)
    {
        $this.storageProvider = $storageProvider
        $this.Logger = $logger
    }

    [CommandHandlerBase] Create([CommandsEnum] $commandType, [string] $commandParams)
    {
        [CommandHandlerBase] $handler = $null
        
        switch($commandType)
        {
            ([CommandsEnum]::UnmanagedRunScript) { $handler = [URunScriptHandler]::new($this.StorageProvider, $this.Logger, $commandParams) } 
            ([CommandsEnum]::Scan) { $handler = [ScanHandler]::new($this.StorageProvider, $this.Logger, $commandParams) } 
            ([CommandsEnum]::SetAlias) { $handler = [SetAliasHandler]::new($this.StorageProvider, $this.Logger) } 
            ([CommandsEnum]::OpenVisualStudio) { $handler = [OpenVS]::new($this.StorageProvider, $this.Logger, $commandParams) } 
            ([CommandsEnum]::RunExe) { $handler = [RunExe]::new($this.StorageProvider, $this.Logger, $commandParams) } 
            default { return $null }
        }

        return $handler;
    }
}