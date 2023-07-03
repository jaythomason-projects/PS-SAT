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

function script:Set-ElementVariables {
    param (
        [Parameter(Mandatory=$true)]
        [object]$Element
    )

    $hashTable = $global:uiElements

    # If the element is a UIElement and has a Name property, add it to the hashtable
    if ($Element -is [System.Windows.UIElement] -and ![string]::IsNullOrEmpty($Element.Name)) {
        $hashTable[$Element.Name] = $Element
    }

    # Go through each child element recursively
    foreach ($childElement in [System.Windows.LogicalTreeHelper]::GetChildren($Element)) {
        if ($childElement -is [System.Windows.DependencyObject]) {
            Set-ElementVariables -Element $childElement
        }
    }
}

function script:Add-TabsToControl {
    param (
        [Parameter(Mandatory=$true)]
        [object]$Tab,
        [Parameter(Mandatory=$true)]
        [object]$Control
    )

    $tabItem = New-Object System.Windows.Controls.TabItem
    $tabItem.Header = $Tab.Header
    $tabItem.Content = $Tab.Tab
    $tabItem.Style = $Control.FindResource("BaseTabItem")
    $Control.Items.Add($tabItem) | Out-Null
}

function Add-ToolboxButtons {
    # TODO: Create function
}

function Show-UserPropertyPanels {
    param (
        [Parameter(Mandatory=$true)]
        [object]$User
    )

    # Update 'Selected User:' text
    $global:uiElements['SelectedUserText'].Text = $User.SamAccountName

    $properties = @(
        "SamAccountName", 
        "DisplayName", 
        "EmployeeID", 
        "Mail", 
        "Company", 
        "Title", 
        "Department", 
        "PasswordLastSet", 
        "AccountExpirationDate",
        "DistinguishedName"
    )

    # Clear child elements in properties panel
    $global:uiElements['PropertiesPanel'].Children.Clear()

    # Loop through each property and create a StackPanel containing a Label and a TextBox
    foreach ($property in $Properties) {
        # Create a StackPanel and child elements
        $stackPanel = New-Object -TypeName System.Windows.Controls.StackPanel

        $label = New-Object -TypeName System.Windows.Controls.Label
        $label.Content = ($property + ":")
        $label.Style = $global:uiPages['UserPropertiesTab'].FindResource("BaseLabel")

        $textBox = New-Object -TypeName System.Windows.Controls.TextBox
        $textBox.Name = ($property + "TextBox")
        $textBox.Style = $global:uiPages['UserPropertiesTab'].FindResource("BaseTextBox")

        # Assign the value of the current property to the TextBox
        $propertyValue = $User.$property
        $textBox.Text = $propertyValue

        # Add the Label and TextBox to the StackPanel
        $stackPanel.Children.Add($label)
        $stackPanel.Children.Add($textBox)

        # Add the StackPanel to the UserInformationPanel
        $global:uiElements['PropertiesPanel'].Children.Add($stackPanel)
    }
}

function Reset-UI {
    # TODO: Create function
}