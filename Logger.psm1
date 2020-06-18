using module .\Global.psm1

class Logger
{
    LogInfo($message)
    {
        Write-Host "[Info $($this.GetCurrentTime())]: $message"
    }

    LogSimpleText($message)
    {
        Write-Host "$message"
    }

    LogError([string] $errorText)
    {
        $ErrorActionPreference = 'Continue'
        Write-Error -Message "[$($this.GetCurrentTime()) Error]: $errorText"
        $ErrorActionPreference = [Global]::ErrorPreferenceOption
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