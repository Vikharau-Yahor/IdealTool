class Global
{
    static [string] $ErrorPreferenceOption = "stop"

    # path to script execution folder (set on startup)
	static [string] $RootPath
    
    #storage pathes
    static [string] $CommandsPath = "\_StorageFiles\Commands.xml"
    static [string] $EntitiesPath = "\_StorageFiles\Entities.xml"
    static [string] $GitReposPath = "\_StorageFiles\GitRepos.xml"
    static [string] $NetProjectsPath = "\_StorageFiles\NetProjects.xml"

    #scripts relative folders
    static [string] $ManagedScriptsPath = "\_Scripts\Managed"
    static [string] $UnManagedScriptsPath = "\_Scripts\UnManaged"
}