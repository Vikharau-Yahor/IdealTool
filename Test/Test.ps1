using namespace System
using namespace System.IO
using namespace System.Reflection
using namespace System.Xml
using namespace System.Xml.Serialization

class Helper
{
    static [void] Serialize([Object] $obj, [string] $toXmlPath)
    {
        [XmlDocument] $doc =  [XmlDocument]::new();

        [Type] $objType = $obj.GetType()
        [Attribute]::GetCustomAttribute($objType, [XmlRootAttribute])
        [XmlRootAttribute]$xmlRootAttribute = [Attribute]::GetCustomAttribute($objType, [XmlRootAttribute])

        if($xmlRootAttribute -eq $null)
        { throw 'XmlRoot attribute is required for serialization object' }

        [string]$rootNodename = if([string]::IsNullOrEmpty($xmlRootAttribute.ElementName)) {$objType.Name} Else {$xmlRootAttribute.ElementName} 
        $rootElemet = [Helper]::CreateNodeFromObject($obj, $null, $doc)               
    }

    static [XmlElement] CreateNodeFromObject([Object] $obj, [XmlElement] $parentNode, [XmlDocument] $doc)
    {
        [XmlElement] $newNode = $null
        [Type] $objType = $obj.GetType()
       
        $objProps = $obj.GetType().GetProperties()
        $objProps | ForEach-Object{
            [PropertyInfo]$prop = $_
            $isArray = $prop.ReflectedType -eq [Array]
            $isCommonType = $prop.ReflectedType.FullName.StartsWith('System')
            if($isArray)
            { 
                [XmlRootAttribute]$xmlElementAttr = [Attribute]::GetCustomAttribute($objType, [XmlRootAttribute])
                if($xmlElementAttr -eq $null)
                { throw "XmlRootAttribute must be specified for property $($prop.Name) of type $($objType.Name)" }

                [string] $containerNodeName = if([string]::IsNullOrEmpty($xmlElementAttr.ElementName)) {$prop.Name} Else {$xmlRootAttribute.ElementName} 
                $containerNodeName+="Container"
                $containerNode = $doc.CreateElement($containerNodeName)
                $propValueCollection = $prop.GetValue()

                [Helper]::CreateNodeFromObject($prop.GetValue(), $containerNode, $doc)
            }
            else
            if($isCommonType)
            {
            }
        }
        return $newNode
    }

    static [XmlElement] ProcessArrayNode()
    {
        [XmlElement] $arrayElement = [XmlElement]::new()

        return $arrayElement
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
[Helper]::Serialize($parent, 'C:\work\Tools\test.xml')

#Get-Member -InputObject $parent -MemberType Properties