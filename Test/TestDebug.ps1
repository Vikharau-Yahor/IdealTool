using namespace System.Linq
using namespace System.Collections
using namespace System.Collections.Generic

[string] $ConfigFullPath
[Dictionary[int, string]] $testDict = [Dictionary[int, string]]::new()
[string[]] $values = @("11")
[List[string]] $list = [List[string]]::new()

$testDict.Add(1,"test")
$testDict.Add(4,"test3")
$testDict.Add(3,"test32")
$testDict.Add(5,"test")
$testDict.Add(2,"test2")
$testDict.ContainsKey(2)
$testDict.Remove(5)
$testDict.Values


$values.GetType()

#$values = $testDict.Values;
#$values
