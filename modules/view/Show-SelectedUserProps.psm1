function Show-SelectedUserProps {
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