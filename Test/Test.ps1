using namespace System
using namespace System.IO
using namespace System.Reflection
using namespace System.Xml
using namespace System.Xml.Serialization

class Helper
{
    static [string] $ContainerNodeNamePart = '-Container'
    static [void] Serialize([Object] $obj, [string] $toXmlPath)
    {
        [XmlDocument] $doc =  [XmlDocument]::new();

        [Type] $objType = $obj.GetType()
        [Attribute]::GetCustomAttribute($objType, [XmlRootAttribute])
        [XmlRootAttribute]$xmlRootAttribute = [Attribute]::GetCustomAttribute($objType, [XmlRootAttribute])

        if($xmlRootAttribute -eq $null)
        { throw 'XmlRoot attribute is required for serialization object' }

        [string]$rootNodename = if([string]::IsNullOrEmpty($xmlRootAttribute.ElementName)) {$objType.Name} Else {$xmlRootAttribute.ElementName} 
        $rootElemet = [Helper]::CreateNodeFromObject($obj, $doc, $rootNodename)
        $doc.AppendChild($rootElemet)

        $doc.Save($toXmlPath)               
    }

    static [XmlElement] CreateNodeFromObject([Object] $obj, [XmlDocument] $doc, [string]$nodeName)
    {
        [XmlElement] $currentNode = $null
        [Type] $objType = $obj.GetType()
        $isObjArray = $objType.BaseType -eq [Array]
        $isObjCommonType = $objType.FullName.StartsWith('System')

        if($isObjCommonType -and -not $isObjArray)
        { 
            $currentNode = $doc.CreateElement($nodeName)
            $currentNode.InnerText = $obj.ToString() 
        }
        elseif ($isObjArray)
        {        
            $childNodeName = $nodeName
            $containerName = $nodeName + [Helper]::ContainerNodeNamePart
            $currentNode = $doc.CreateElement($containerName)
            $obj | ForEach-Object { 
                if($_ -ne $null) { 
                    $childNode = [Helper]::CreateNodeFromObject($_, $doc, $childNodeName)
                    $currentNode.AppendChild($childNode) 
                }
            }
        }
        else
        {
            $currentNode = $doc.CreateElement($nodeName)
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
                     #$nextNodeName += if($isPropArray) {[Helper]::ContainerNodeNamePart} Else {[string]::Empty} 
                     $childNode = [Helper]::CreateNodeFromObject($propValue, $doc, $nextNodeName)
                     $currentNode.AppendChild($childNode)
                }
            }
        }
        return $currentNode
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
    #if w/o attribute then this value will go to attribute to the
    [string] $Name
    [string] $LastName

    #if attribute specified - new node will be created with Prop name or custom value
    [XmlElement("Child")]
    [Child] $_Child

    #required attribute for any array, generated nodes: root node name = ProfessionContainer (or ProffsContainer if value is not specified); childs = Profession 
    [XmlElement("Profession")]
    [string[]] $Proffs
}


$child = [Child]::new()
$child.Age = 12
$child.ChildName = 'Kostya'

$parent = [Person]::new()
$parent._Child = $child
$parent.Name = 'Ivan'
$parent.LastName = 'Ivanov'
$parent.Proffs = @('prof1','prof2')
[Helper]::Serialize($parent, 'E:\test.xml')

#Get-Member -InputObject $parent -MemberType Properties