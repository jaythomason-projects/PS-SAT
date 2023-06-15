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

function Set-ElementVariables {
    param (
        [Parameter(Mandatory=$true)]
        [object]$Element
    )

    # If the element is a UIElement and has a Name property, add it to the hashtable
    if ($Element -is [System.Windows.UIElement] -and ![string]::IsNullOrEmpty($Element.Name)) {
        $global:uiElements[$Element.Name] = $Element
    }

    # Go through each child element recursively
    foreach ($childElement in [System.Windows.LogicalTreeHelper]::GetChildren($Element)) {
        if ($childElement -is [System.Windows.DependencyObject]) {
            Set-ElementVariables -Element $childElement
        }
    }
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