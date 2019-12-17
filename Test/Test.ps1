using namespace System
using namespace System.IO
using namespace System.Reflection
using namespace System.Xml
using namespace System.Xml.Serialization
using module ..\Utils\CommonHelper.psm1

class Helper
{
    static [void] Serialize([Object] $obj, [string] $toXmlPath)
    {
        [XmlDocument] $doc =  [XmlDocument]::new();
        [Type] $objType = $obj.GetType()
        [XmlRootAttribute]$xmlRootAttribute = [Attribute]::GetCustomAttribute($objType, [XmlRootAttribute])

        [string]$rootNodename = [CH]::Ternary([string]::IsNullOrEmpty($xmlRootAttribute.ElementName), $objType.Name, $xmlRootAttribute.ElementName)
        $rootElemet = [Helper]::CreateNodeFromObject($obj, $doc, $rootNodename)
        $doc.AppendChild($rootElemet)
        $doc.Save($toXmlPath)               
    }

    static [XmlElement] CreateNodeFromObject([Object] $obj, [XmlDocument] $doc, [string]$nodeName)
    {
        [XmlElement] $currentNode = $doc.CreateElement($nodeName)
        [Type] $objType = $obj.GetType()
        $isObjArray = $objType.BaseType -eq [Array]
        $isObjCommonType = $objType.FullName.StartsWith('System')

        if($isObjCommonType -and -not $isObjArray)
        { 
            $currentNode.InnerText = $obj.ToString() 
        }
        elseif ($isObjArray)
        {        
            $anyChild = ($obj | Where-Object { $_ -ne $null } | select -First 1)
            
            if ($anyChild -eq $null) { return $currentNode }
            $childNodeName = $anyChild.GetType().Name

            $obj | ForEach-Object { 
                if($_ -ne $null) { 
                    $childNode = [Helper]::CreateNodeFromObject($_, $doc, $childNodeName)
                    $currentNode.AppendChild($childNode) 
                }
            }
        }
        else
        {
            $objProps = $objType.GetProperties()
            $objProps | ForEach-Object {
                [PropertyInfo]$prop = $_
                $propValue = $prop.GetValue($obj)
                
                if($propValue -eq $null)
                { return }
                $isPropString = $prop.PropertyType -eq [String]
                $isPropArray = $prop.PropertyType.BaseType -eq [Array]
                $isPropCommonType = ($prop.PropertyType.FullName.StartsWith('System')) -and (-not $isPropArray -or $isPropString)

                if($isPropCommonType)
                {
                    $currentNode.SetAttribute($prop.Name, $propValue)
                }
                else{
                     [XmlElementAttribute]$xmlElementAttr = [Attribute]::GetCustomAttribute($prop, [XmlElementAttribute])
                     [string] $nextNodeName = if([string]::IsNullOrEmpty($xmlElementAttr.ElementName)) {$prop.Name} Else {$xmlElementAttr.ElementName}  
                     $childNode = [Helper]::CreateNodeFromObject($propValue, $doc, $nextNodeName)
                     $currentNode.AppendChild($childNode)
                }
            }
        }
        return $currentNode
    }

    static [Object] Deserialize([Type] $objType, [string] $fromXmlPath)
    {
        [bool]$isXmlFileExisted = -not (Test-Path $fromXmlPath)
        [CH]::ThrowError($isXmlFileExisted, "Xml file doesn't exists. Path: $fromXmlPath")

        [XmlDocument] $doc =  [XmlDocument]::new()
        $doc.Load($fromXmlPath)

        [XmlRootAttribute]$xmlRootAttribute = [Attribute]::GetCustomAttribute($objType, [XmlRootAttribute])
        [string]$rootNodename = [CH]::Ternary([string]::IsNullOrEmpty($xmlRootAttribute.ElementName), $objType.Name, $xmlRootAttribute.ElementName)
        [XmlNode]$rootNode = $doc.ChildNodes[0]
        [CH]::ThrowError($rootNode -eq $null, "XML file is empty (or doesn't contain xml nodes)")
        [CH]::ThrowError($rootNode.Name -ne $rootNodename, "XML contains unexpected root node with name: '$($rootNode.Name)' but expected: '$rootNodename'")
        $deserializedObject = [Helper]::DeserializeNode($objType, $rootNode)  
        return $deserializedObject             
    }
    static [Object] DeserializeNode([Type] $objType, [XmlNode] $node)
    {
        $obj = [Activator]::CreateInstance($objType);
        $isObjArray = $objType.BaseType -eq [Array]
        $isObjCommonType = $objType.FullName.StartsWith('System')

        if($isObjCommonType -and -not $isObjArray)
        { 
            $obj =  [Convert]::ChangeType($node.InnerText, $objType)
        }
        elseif ($isObjArray)
        {
           [XmlNode] $anyChildNode = ($node.ChildNodes | select -First 1)
            
            if ($anyChildNode -eq $null) { return $obj }

            $a = $objType 
        }
        else
        {
            $objProps = $objType.GetProperties()
            $objProps | ForEach-Object {
                [PropertyInfo]$prop = $_ 
                $isPropString = $prop.PropertyType -eq [String]
                $isPropArray = $prop.PropertyType.BaseType -eq [Array]
                $isPropCommonType = ($prop.PropertyType.FullName.StartsWith('System')) -and (-not $isPropArray -or $isPropString)

                if($isPropCommonType)
                {
                    $nodeAttr = $node.Attributes.GetNamedItem($prop.Name)
                    
                    if($nodeAttr -eq $null)
                    { return }

                    $prop.SetValue($obj, [Convert]::ChangeType($nodeAttr.Value, $prop.PropertyType))                    
                }
                else
                {
                    [XmlElementAttribute]$xmlElementAttr = [Attribute]::GetCustomAttribute($prop, [XmlElementAttribute])
                    [string] $searchNodeName = if([string]::IsNullOrEmpty($xmlElementAttr.ElementName)) {$prop.Name} Else {$xmlElementAttr.ElementName}  
                    [XmlNode] $matchedNode = ($node.ChildNodes | Where-Object { $_.Name -eq $searchNodeName } | Select-Object -First 1)
                    
                    $propValue = [CH]::Ternary($matchedNode -eq $null, $null, [Helper]::DeserializeNode($prop.PropertyType, $matchedNode))  
                    $prop.SetValue($obj, $propValue)          
                }
            }
        }

        return $obj

        # create obj
        # check its type
        # if (is system type)
        #    set value for object from innerText of node
        #    + return object
        # if (array)
        #  check that $childNode.Name == arrayElementType
        #  foreach($childNode in $node.ChildNodes)
        #     obj.Add(elementType, $childNode    
        # if (complex)
        #   foreach($prop in $objType.GetProperties)
        #     if $prop is system
        #        locate attribute + set prop value in obj
        #     if $ prop is complex 
        #        $nextNode = locate node in childNodes
        #        $prop.SetValue(Deserialize($prop.Type, $nextNode)
    }

}

class Child
{
    [string] $ChildName
    [int] $Age
}

#root element: Class name or custom value (processed only if this class is Top parent object)
[XmlRoot("PersonRoot")]
class Person
{
    #if w/o attribute then this value will go to attribute to the parent node
    [string] $Name
    [string] $LastName

    #if attribute specified - new node will be created with Prop name or custom value
    [XmlElement("Child")]
    [Child] $_Child

    #array of system types is 
    [XmlElement("Professions")]
    [string[]] $Proffs 

    [XmlElement("Childs")]
    [Child[]] $Children
}


$child = [Child]::new()
$child.Age = 12
$child.ChildName = 'Kostya'

$child2 = [Child]::new()
$child2.Age = 13
$child2.ChildName = 'Artsiom'

$parent = [Person]::new()
$parent._Child = $child
$parent.Name = 'Ivan'
$parent.LastName = 'Ivanov'
$parent.Proffs = @('prof1','prof2')
$parent.Children = @($child2, $child)
[Helper]::Serialize($parent, 'C:\work\test.xml')
$deserialized = [Helper]::Deserialize([Person],'C:\work\test.xml')
#Get-Member -InputObject $parent -MemberType Properties