function script:New-XmlObjectFromXamlString {
    param (
        [Parameter(Mandatory=$true)]
        [string]$XamlString
    )

    $stringReader = New-Object System.IO.StringReader($XamlString)
    $xmlReader = [System.Xml.XmlReader]::Create($stringReader)
    $xmlObject = [System.Windows.Markup.XamlReader]::Load($xmlReader)

    return $xmlObject
}

function Add-TabItems {
    # TODO: Create function
}

function Add-ToolboxButtons {
    # TODO: Create function
}

function Add-UserPropertyPanels {
    # TODO: Create function
}