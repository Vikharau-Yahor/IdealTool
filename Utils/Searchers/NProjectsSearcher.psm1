using namespace System.Collections.Generic
using namespace System.IO
using namespace Microsoft.Build.Construction

using module ..\Helpers\XMLHelper.psm1
using module ..\Helpers\EntityHelper.psm1
using module ..\..\Logger.psm1
using module ..\..\Models\NetModels.psm1
using module ..\..\Models\EntityType.psm1

class NProjectsSearcher
{
    hidden [string] $slnMask = '*.sln'
    hidden [string] $projExt = '.csproj'
    hidden [Logger] $logger

    NProjectsSearcher([Logger] $logger)
    {
        $this.logger = $logger
    }
    
    [NSolution[]] SearchSolutions([string] $searchPath)
    {
        $foundSolutionPathes = Get-ChildItem -Path $searchPath $this.slnMask -Recurse
             
        [List[NSolution]] $solutions = @()

        $foundSolutionPathes | ForEach-Object {
            $solutionPath = $_
            [NSolution] $solution = [NSolution]::new()
            $solution.Name = $_.Name
            $solution.Path = Split-Path $_.FullName
            $solution.Id = [EntityHelper]::GenerateId([EntityType]::NSolution, $solution.Name, $solution.Path)
            $solutions.Add($solution)
        }

        $solutions | ForEach-Object {
            [NSolution] $solution = $_
            [List[NProject]] $projects = @()
            $solutionFullPath = "$($solution.Path)\$($solution.Name)"
            $slnProjectsPathes = (dotnet sln $solutionFullPath list) | Select-Object -Skip 2 | Where-Object {$_.EndsWith($projExt)}
            $slnProjectsPathes | ForEach-Object {
                [NProject] $project = [NProject]::new()
                $project.Name = $_ | Split-Path -Leaf
                $project.RelativePath = $_ | Split-Path
                $project.Id = [EntityHelper]::GenerateId([EntityType]::NProj, $project.Name, "$($solution.Path)\$($project.RelativePath)")
                $projects.Add($project)
            }

            $solution.NProjects = $projects.ToArray()
        }

        $this.Logger.LogInfo("Net Solutions found: $($solutions.Count)") 
        return $solutions.ToArray()  
    }
}