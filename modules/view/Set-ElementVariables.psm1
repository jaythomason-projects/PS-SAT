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