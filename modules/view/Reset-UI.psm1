function Reset-UI {
    # Update 'Selected User:' text
    $global:uiElements['SelectedUserText'].Text = "None"

    # Clear child elements in properties panel
    $global:uiElements['PropertiesPanel'].Children.Clear()
}