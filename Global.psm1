class Global
{
    static [string] $ErrorPreferenceOption = "stop"

    # path to script execution folder (set on startup)
	static [string] $RootPath
    
    # static storages - can not be deleted
    static [string] $CommandsPath = "\_StorageFiles\Static\Commands.xml"
    
    # cache storages - used to restore data for new dynamic storage items which where used before 
    static [string] $CachedActionItemsPath = "\_StorageFiles\Cache\ActionItemsCache.xml"

    #dynamic storage pathes - dynamically created via commands, all necessary data restored from cache (if existing)
    static [string] $ActionItemsPath = "\_StorageFiles\Dynamic\ActionItems.xml"
    static [string] $GitReposPath = "\_StorageFiles\Dynamic\GitRepos.xml"
    static [string] $NetProjectsPath = "\_StorageFiles\Dynamic\NetProjects.xml"

    #scripts relative folders
    static [string] $ManagedScriptsPath = "\_Scripts\Managed"
    static [string] $UnManagedScriptsPath = "\_Scripts\UnManaged"
}