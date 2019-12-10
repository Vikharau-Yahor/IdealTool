class Logger
{
    LogInfo($message)
    {
        Write-Host "[Info $($this.GetCurrentTime())]: $message"
    }

    LogError([string] $errorText)
    {
        Write-Error -Message "[$($this.GetCurrentTime()) Error]: $errorText"
    }

    LogError([Exception] $exception)
    {
        Write-Error -Exception $exception
    }

    [string] GetCurrentTime()
    {
        return Get-Date -Format "HH:mm"
    }
}