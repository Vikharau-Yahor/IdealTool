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