#Enum command number must be equal to Id xml attribute
enum CommandsEnum
{
    Quit = 0
    Scan = 1
    Run = 2
    UnmanagedRun = 3
    OpenVisualStudio = 4
    OpenRider = 5
    SetAlias = 6
}

# TO DO
# - entityStorage (adds, get meta info (id, alias, type) for entities by alias)
# - xml file for entity storage
# - set alias command - get all git-projects, net projects and etc which has no aliases in entity storage; request input from user; add new entity to entity storage
#
#