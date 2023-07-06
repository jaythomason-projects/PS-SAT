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