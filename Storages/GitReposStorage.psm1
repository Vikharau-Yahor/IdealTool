using namespace System.Collections.Generic

using module ..\Models\GitRepo.psm1
using module ..\Utils\Helpers\XmlHelper.psm1
using module ..\Logger.psm1

class GitReposStorage
{ 
    
    [string] $ConfigFullPath
    [GitRepo[]] $GitRepos
    [Logger] $Logger

    GitReposStorage([string]$cfgPath, [Logger] $logger)
    {
        $this.ConfigFullPath = $cfgPath
        $this.Logger = $logger
        $this.Reload()
    }

    Reload()
    {
        $this.GitRepos = @()

        if(-not (Test-Path -Path $this.ConfigFullPath))
        { return }
               
        try
        {
            [GitReposContainer]$gitReposContainer = [XmlHelper]::Deserialize([GitReposContainer], $this.ConfigFullPath)
            
            if( $gitReposContainer -eq $null -or $gitReposContainer.GitRepositories -eq $null)
            { return }

            $this.GitRepos = $gitReposContainer.GitRepositories
        }
        catch [System.Exception]
        {
            $this.Logger.LogError("Git repositories deserialization has been failed from file: $($this.ConfigFullPath). Exception:$($_.Exception)")         
        }
    }

    Save([GitRepo[]] $gitRepos)
    {
         if($gitRepos -eq $null -or $gitRepos.Count -eq 0)
         { 
            $this.Logger.LogInfo("GitStorage saves nothing because input gitRepos array is empty")
            return 
         }

         [GitReposContainer] $gitReposContainer = [GitReposContainer]::new()
         $gitReposContainer.GitRepositories = $gitRepos

         [XmlHelper]::Serialize($gitReposContainer, $this.ConfigFullPath)
         $this.Logger.LogInfo("New git repositories have been successfully saved to file: $($this.ConfigFullPath)")
    }
}