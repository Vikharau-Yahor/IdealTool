using namespace System
using namespace System.IO
using namespace System.Reflection
using namespace System.Xml
using namespace System.Xml.Serialization
using module .\CommonHelper.psm1

class XmlHelper
{
    #public
    static [void] Serialize([Object] $obj, [string] $toXmlPath)
    {
        [XmlDocument] $doc =  [XmlDocument]::new();
        [Type] $objType = $obj.GetType()
        [XmlRootAttribute]$xmlRootAttribute = [Attribute]::GetCustomAttribute($objType, [XmlRootAttribute])

        [string]$rootNodename = [CH]::Ternary([string]::IsNullOrEmpty($xmlRootAttribute.ElementName), $objType.Name, $xmlRootAttribute.ElementName)
        $rootElemet = [XmlHelper]::SerializeObjToXmlNode($obj, $doc, $rootNodename)
        $doc.AppendChild($rootElemet)
        $doc.Save($toXmlPath)               
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
        [CH]::ThrowError($rootNode.LocalName -ne $rootNodename, "XML contains unexpected root node with name: '$($rootNode.LocalName)' but expected: '$rootNodename'")
        
        $deserializedObject = [XmlHelper]::DeserializeNode($objType, $rootNode)  
        return $deserializedObject             
    }

    #private
    hidden static [XmlElement] SerializeObjToXmlNode([Object] $obj, [XmlDocument] $doc, [string]$nodeName)
    {
        [XmlElement] $currentNode = $doc.CreateElement($nodeName)
        [Type] $objType = $obj.GetType()
        $isObjArray = $objType.BaseType -eq [Array]
        $isObjCommonType = $objType.FullName.StartsWith('System')
        $isObjEnum = $objType.BaseType -eq [Enum]

        if($isObjCommonType -and -not $isObjArray)
        { 
            $currentNode.InnerText = $obj.ToString() 
        }
        elseif($isObjEnum)
        { 
            $objEnumValue = [Enum]::Parse($objType, $obj).value__
            $currentNode.InnerText = $objEnumValue 
        }
        elseif ($isObjArray)
        {        
            $anyChild = ($obj | Where-Object { $_ -ne $null } | select -First 1)
            
            if ($anyChild -eq $null) { return $currentNode }
            $childNodeName = $anyChild.GetType().Name

            $obj | ForEach-Object { 
                if($_ -ne $null) { 
                    $childNode = [XmlHelper]::SerializeObjToXmlNode($_, $doc, $childNodeName)
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

                if([Attribute]::GetCustomAttribute($prop, [XmlIgnoreAttribute]) -ne $null)
                { return }

                $isPropString = $prop.PropertyType -eq [String]
                $isPropArray = $prop.PropertyType.BaseType -eq [Array]
                $isPropEnum= $prop.PropertyType.BaseType -eq [Enum]
                $isPropCommonTypeExceptArray = ($prop.PropertyType.FullName.StartsWith('System')) -and (-not $isPropArray -or $isPropString)

                if($isPropCommonTypeExceptArray)
                {                  
                    $currentNode.SetAttribute($prop.Name, $propValue)
                }
                elseif($isPropEnum)
                {
                    $enumValue = [Enum]::Parse($prop.PropertyType, $propValue).value__
                    $currentNode.SetAttribute($prop.Name, $enumValue)
                }
                else
                {
                     [XmlElementAttribute]$xmlElementAttr = [Attribute]::GetCustomAttribute($prop, [XmlElementAttribute])
                     [string] $nextNodeName = if([string]::IsNullOrEmpty($xmlElementAttr.ElementName)) {$prop.Name} Else {$xmlElementAttr.ElementName}  
                     $childNode = [XmlHelper]::SerializeObjToXmlNode($propValue, $doc, $nextNodeName)
                     $currentNode.AppendChild($childNode)
                }
            }
        }
        return $currentNode
    }

    hidden static [Object] DeserializeNode([Type] $objType, [XmlNode] $node)
    {
        $isObjArray = $objType.BaseType -eq [Array]
        $isObjCommonType = $objType.FullName.StartsWith('System')
        $isObjEnum= $objType.BaseType -eq [Enum]

        if($isObjCommonType -and -not $isObjArray)
        {           
            $obj = [Convert]::ChangeType($node.InnerText, $objType)
        }
        elseif($isObjEnum)
        {
             $obj = [Enum]::Parse($objType, $node.InnerText)
        }
        elseif ($isObjArray)
        {
            [Type] $arrayElementType = $objType.GetElementType()
            [XmlNode] $anyChildNode = ($node.ChildNodes | Select-Object -First 1)
            
            if ($anyChildNode -eq $null) { return [Array]::CreateInstance($arrayElementType, 0) }

            [Array]$obj = [Array]::CreateInstance($arrayElementType, $node.ChildNodes.Count);

            $nodeIndex = 0
            $node.ChildNodes | ForEach-Object { 
                [XmlNode]$childNode = $_
                $arrayItem = [XmlHelper]::DeserializeNode($arrayElementType, $childNode)
                $obj[$nodeIndex] = $arrayItem
                $nodeIndex += 1
            }
             
        }
        else
        {
            $obj = [Activator]::CreateInstance($objType);
            $objProps = $objType.GetProperties()
            $objProps | ForEach-Object {
                [PropertyInfo]$prop = $_ 
                $isPropString = $prop.PropertyType -eq [String]
                $isPropArray = $prop.PropertyType.BaseType -eq [Array]
                $isPropEnum= $prop.PropertyType.BaseType -eq [Enum]
                $isPropCommonType = ($prop.PropertyType.FullName.StartsWith('System')) -and (-not $isPropArray -or $isPropString)

                if($isPropCommonType)
                {
                    $nodeAttr = $node.Attributes.GetNamedItem($prop.Name)
                    
                    if($nodeAttr -eq $null)
                    { return }

                    $prop.SetValue($obj, [Convert]::ChangeType($nodeAttr.Value, $prop.PropertyType))                    
                }
                elseif($isPropEnum)
                {
                    $nodeAttr = $node.Attributes.GetNamedItem($prop.Name)
                   
                    if($nodeAttr -eq $null)
                    { return }

                    $enumValue = [Enum]::Parse($prop.PropertyType, $nodeAttr.Value)
                    $prop.SetValue($obj, $enumValue)  
                }
                else
                {
                    [XmlElementAttribute]$xmlElementAttr = [Attribute]::GetCustomAttribute($prop, [XmlElementAttribute])
                    [string] $searchNodeName = [CH]::Ternary([string]::IsNullOrEmpty($xmlElementAttr.ElementName), $prop.Name, $xmlElementAttr.ElementName)  
                    [XmlNode] $matchedNode = ($node.ChildNodes | Where-Object { $_.LocalName -eq $searchNodeName } | Select-Object -First 1)
                    $propValue = $null

                    if($matchedNode -ne $null)
                    {
                        $propValue = [CH]::Ternary($matchedNode -eq $null, $null, [XmlHelper]::DeserializeNode($prop.PropertyType, $matchedNode)) 
                    } 

                    $prop.SetValue($obj, $propValue)          
                }
            }
        }

        return $obj
    }
}