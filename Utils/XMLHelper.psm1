using namespace System
using namespace System.IO
using namespace System.Xml.Serialization

class XmlHelper
{
    static [void] Serialize([Object] $obj, [string] $toXmlPath)
    {
        [Type] $objType = $obj.GetType()
        [XmlSerializer] $serializer = [XmlSerializer]::new($objType);
        [FileStream] $fs = [FileStream]::new($toXmlPath, [FileMode]::OpenOrCreate)

        try
        {
            $serializer.Serialize($fs, $obj);
        }
        finally
        {
            $fs.Dispose()
        }
    }

    static [Object] Deserialize([Type] $deserializeType, [string] $toXmlPath)
    {
        if(-not (Test-Path -Path $toXmlPath))
        { 
            throw "Xml file doesn't exists: $toXmlPath"
        }

        [XmlSerializer] $serializer = [XmlSerializer]::new($deserializeType);
        [FileStream] $fs = [FileStream]::new($toXmlPath, [FileMode]::Open)
        $deserializedObj = $null
        
        try
        {
            $deserializedObj = $serializer.Deserialize($fs)
        }
        finally
        {
            $fs.Dispose()
        }

        return $deserializedObj
    }
}