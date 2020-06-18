using namespace System.Linq
using namespace System.Collections.Generic

using module ..\Models\_BaseActionItem.psm1
using module ..\Models\ActionItem.psm1
using module ..\Models\ActionItemType.psm1
using module ..\Logger.psm1

class AbstractActionItemsStorage
{ 
    [string] $ConfigFullPath
    [Logger] $Logger

    AbstractActionItemsStorage([string]$cfgPath, [Logger] $logger)
    {
        $this.ConfigFullPath = $cfgPath
        $this.Logger = $logger
    }

    Reload()
    {
        throw "Reload() must be implemented in inherited class"
    }

    Update([ActionItem[]] $actionItems)
    {
        throw "Update() must be implemented in inherited class"
    }
}