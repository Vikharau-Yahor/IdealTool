using module ..\..\Logger.psm1

class BaseTool
{
    [Logger] $Logger

    BaseTool([Logger] $logger)
    {
        $this.Logger = $logger
    }
}