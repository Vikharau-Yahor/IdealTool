using module .\CommandModifiersEnum.psm1

class CommandModifier
{
    #Any modifier obtains its Id only once
    [CommandModifiersEnum] $Id

    #aliases stored w/o '-'
    [string] $Alias
}