using namespace System.Linq
using namespace System.Collections.Generic

[string] $ConfigFullPath
[Dictionary[int, string]] $testDict = [Dictionary[int, string]]::new()
[string[]] $values = @("11")

$testDict.Add(1,"test")
$testDict.Add(2,"test2")
$values = $testDict.Values;
$values
