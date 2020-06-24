using namespace System.Collections.Generic
using namespace System.IO
using namespace Microsoft.Build.Construction

using module ..\Helpers\XMLHelper.psm1
using module ..\Helpers\ActionItemHelper.psm1
using module ..\Helpers\CommonHelper.psm1
using module ..\..\Logger.psm1
using module ..\..\Models\ActionItem.psm1
using module ..\..\Models\NetModels.psm1
using module ..\..\Models\ActionItemType.psm1
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
    
    [DotNetItemsContainer] SearchDotNetItems([string] $searchPath)
    {
        $this.Logger.LogInfo("Start Net solutions and projects search") 
        $foundSolutionPathes = Get-ChildItem -Path $searchPath $this.slnMask -Recurse
             
        [List[NSolution]] $solutions = @()
        [Dictionary[string, NProject]] $projectsByPath = [Dictionary[string, NProject]]::new()

        $foundSolutionPathes | ForEach-Object {
            $solutionPath = $_
           
            #setup base data
            $path = $solutionPath.FullName
            $baseInfo = [ActionItem]::new($solutionPath.Name, $path, $true, [ActionItemType]::NSolution)

            [NSolution] $newSolution = [NSolution]::new()
            $newSolution.SetInitialBasicData($baseInfo)
            $newSolution.ProjectsIds = @()
            $solutions.Add($newSolution)
        }

        foreach($solution in $solutions) {
            [List[string]] $projectsIdsList = [List[string]]::new()
            $solutionBaseData = $solution.GetBaseData()
            $solutionFullPath = "$($solutionBaseData.Path)"
            $slnProjectsPathes = (dotnet sln $solutionFullPath list) | Select-Object -Skip 2 | Where-Object {$_.EndsWith($projExt)}
            
            if($slnProjectsPathes -eq $null -or  $slnProjectsPathes.Count -eq 0)
            {
                $solution.GetBaseData().IsActive = $false
                continue
            }
            
            foreach ($relativeProjectPath in $slnProjectsPathes) {
                $slnPath = Split-Path $solutionBaseData.Path
                [string] $projectFullPath = "$($slnPath)\$($relativeProjectPath)"
                
                [NProject] $project = [NProject]::new()
                if(-not (Test-Path $projectFullPath))
                { continue }
                
                if($projectsByPath.ContainsKey($projectFullPath))
                {
                    $project = $projectsByPath[$projectFullPath]
                }
                else {        
                    #setup base data
                    $name = $relativeProjectPath | Split-Path -Leaf       
                    $baseInfo = [ActionItem]::new($name, $projectFullPath, $false, [ActionItemType]::NProj)  
                    $project.SetInitialBasicData($baseInfo)

                    #additional data
                    $project.Type = $this.NProjectTypeExtractor.ExtractType($projectFullPath)
                    $project.GetBaseData().IsActive = $project.IsPrimary()
                    $project.SolutionsIds = @()
                    $projectsByPath.Add($projectFullPath, $project)
                }
                $projectsIdsList.Add($project.Id)
            }
            $solution.ProjectsIds = $projectsIdsList.ToArray()
        }
        foreach($project in $projectsByPath.Values)
        {
            $relatedSolutions = $solutions | Where-Object { $_.ProjectsIds.Contains($project.Id) }
            $relatedSolutions = [CH]::Ternary($relatedSolutions -eq $null, @(), $relatedSolutions)
            
            $project.SolutionsIds = [string[]]::new($relatedSolutions.Count)
            $index = 0
            foreach($solution in $relatedSolutions)
            {
                $project.SolutionsIds[$index] = $solution.Id
                $index += 1
            }
        }

        [DotNetItemsContainer] $container = [DotNetItemsContainer]::new()
        $container.NetProjects = $projectsByPath.Values
        $container.NetSolutions = $solutions.ToArray()
        $this.Logger.LogInfo("New .net solutions found: $($container.NetSolutions.Count)") 
        $this.Logger.LogInfo("New .net projects found: $($container.NetProjects.Count)") 
        return $container
    }
}