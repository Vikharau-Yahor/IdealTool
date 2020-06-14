using namespace System.Collections.Generic
using namespace System.IO
using namespace Microsoft.Build.Construction

using module ..\Helpers\XMLHelper.psm1
using module ..\Helpers\EntityHelper.psm1
using module ..\..\Logger.psm1
using module ..\..\Models\NetModels.psm1
using module ..\..\Models\EntityType.psm1
using module ..\DotNet\NProjectTypeExtractor.psm1

class NProjectsSearcher
{
    hidden [string] $slnMask = '*.sln'
    hidden [string] $projExt = '.csproj'
    hidden [Logger] $logger
    hidden [NProjectTypeExtractor] $NProjectTypeExtractor

    NProjectsSearcher([Logger] $logger)
    {
        $this.logger = $logger
        $this.NProjectTypeExtractor = [NProjectTypeExtractor]::new()
    }
    
    [NSolution[]] SearchSolutions([string] $searchPath)
    {
        $this.Logger.LogInfo("Start Net solutions and projects search") 
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
                [string] $relativeProjectPath = $_
                [string] $projectFullPath = "$($solution.Path)\$($relativeProjectPath)"
                if(Test-Path $projectFullPath)
                {
                    $project.Name = $relativeProjectPath | Split-Path -Leaf
                    $project.RelativePath = $relativeProjectPath | Split-Path
                    $project.Type = $this.NProjectTypeExtractor.ExtractType("$($solution.Path)\$($relativeProjectPath)")
                    #$project.IsPrimary = $project.Type -ne [NProjectType]::Dll
                    $project.Id = [EntityHelper]::GenerateId([EntityType]::NProj, $project.Name, "$($solution.Path)\$($project.RelativePath)")
                    $projects.Add($project)
                }
            }

            $solution.NProjects = $projects.ToArray()
        }

        $this.Logger.LogInfo("Net Solutions found: $($solutions.Count)") 
        return $solutions.ToArray()  
    }
}