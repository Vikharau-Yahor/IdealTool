class Global
{
    static [string] $ErrorPreferenceOption = "stop"

	static [string] $RootPath
    
    static [string] $CommandsPath = "\_StorageFiles\Commands.xml"
    static [string] $GitReposPath = "\_StorageFiles\GitRepos.xml"
    static [string] $NetProjectsPath = "\_StorageFiles\NetProjects.xml"

    static [string] $ManagedScriptsPath = "\_Scripts\Managed"
    static [string] $UnManagedScriptsPath = "\_Scripts\UnManaged"
}