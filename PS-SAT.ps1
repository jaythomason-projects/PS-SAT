# param(
# TODO: Add a debug switch, and a skip admin prompt switch
# )

# ==============================
# SETUP
# ==============================
# Set strict mode
Set-StrictMode -Version Latest

# Stop the script if any command fails
$ErrorActionPreference = "Stop"

# Try to add assemblies
$assemblies = @(
    "PresentationFramework"
    "PresentationCore"
    "WindowsBase"
    "System.Windows.Forms"
)

foreach ($assembly in $assemblies) {
    try {
        Add-Type -AssemblyName $assembly
        Write-Host "Successfully loaded assembly: $assembly"
    } catch {
        Write-Error "Failed to load assembly: $assembly. Error: $_. Exiting script."
        return
    }
}

# Set paths
$moduleFolderPath               = Join-Path $PSScriptRoot "modules"
$resourceFolderPath             = Join-Path $PSScriptRoot "resources"
$configFilePath                 = Join-Path $PSScriptRoot "config.json"

# Validate paths
if (-not (Test-Path -Path $moduleFolderPath -PathType Container)) {
    Write-Error "Modules folder path does not exist. Exiting script."
    return
}

if (-not (Test-Path -Path $resourceFolderPath -PathType Container)) {
    Write-Error "Resources folder path does not exist. Exiting script."
    return
}

if (-not (Test-Path -Path $configFilePath)) {
    Write-Error "Configuration file path does not exist. Exiting script."
    return
}

# Try to import config
try {
    $config = (Get-Content -Path $configFilePath) | ConvertFrom-Json
} catch {
    Write-Error "Failed to load or parse config file. Error: $_. Exiting script."
    return
}

# ==============================
# MODEL
# ==============================
# Get all module files
$moduleFiles = Get-ChildItem -Path $moduleFolderPath -Filter *.psm1 -Recurse

foreach ($moduleFile in $moduleFiles) {
    # Set paths
    $moduleFilePath = $moduleFile.FullName

    # Try to import the module
    try {
        Import-Module -Name $moduleFilePath
        Write-Host "Successfully imported module: $moduleFilePath"
    } catch {
        Write-Error "Failed to import module: $moduleFilePath. Error: $_. Exiting script."
        return
    }
}

# ==============================
# VIEW
# ==============================
# Get all XAML files, except the sharedResources XAML file
$xamlStrings = @{}
$xamlFiles = Get-ChildItem -Path $resourceFolderPath -Filter *.xaml | Where-Object { $_.Name -ne "sharedResources.xaml" }

foreach ($xamlFile in $xamlFiles) {
    # Set paths
    $xamlFilePath = $xamlFile.FullName

    # Import the XAML file as a string
    $xamlString = Get-Content -Path $xamlFilePath -Raw

    # Fix relative path issue: Replace empty ResourceDictionary element with shared resources path in XAML
    $modifiedXamlString = $xamlString -replace '%RESOURCE_PATH%', $resourceFolderPath

    # Add each XAML string to a hashtable
    $xamlName = $xamlFile -replace ".xaml", ""
    $xamlStrings[$xamlName] = $modifiedXamlString
    Write-Host "Successfully imported XAML string: $xamlFilePath"
}

# Define UI pages, then create parent windows and tabs
$global:uiPages = @{
    MainWindow = @{}
    UserPropertiesTab = @{}
    LogTab = @{}
}

$global:uiPages['MainWindow']                   = New-XmlObjectFromXamlString -XamlString $xamlStrings['mainWindow']
$global:uiPages['LoadingWindow']                = New-XmlObjectFromXamlString -XamlString $xamlStrings['loadingWindow']
$global:uiPages['UserPropertiesTab']            = New-XmlObjectFromXamlString -XamlString $xamlStrings['userPropertiesTab']
$global:uiPages['LogTab']                       = New-XmlObjectFromXamlString -XamlString $xamlStrings['logTab']

# Assign variables to each named element in UI pages
$global:uiElements = @{}

foreach ($value in $uiPages.Values) {
    Set-ElementVariables -Element $value
}

# Order tabs and define headers, then add to tab control
$tabs = [ordered]@{
    "UserInformationTab" = @{
        Tab = $uiPages['UserPropertiesTab']
        Header = "User Properties"
    }
    "LogTab" = @{
        Tab = $uiPages['LogTab']
        Header = "Notes/Log"
    }
}

foreach ($tab in $tabs.Values) {
    Add-TabsToControl -Tab $tab -Control $global:uiElements["TabControl"]
}

# ==============================
# CONTROL
# ==============================
# Add event handlers
$global:uiElements["SearchNameButton"].Add_Click({
    $Arguments = @{
        Properties = @("DisplayName", "SamAccountName")
        String = $global:uiElements["SearchInputTextBox"].Text.Trim()
        FilterSearch = $true
    }
    $selectedUser = Get-SelectedUser $Arguments

    if ($selectedUser) {
        Show-SelectedUserProps -User $selectedUser
    }
})

$global:uiElements["SearchIDButton"].Add_Click({
    $Arguments = @{
        Properties = @("EmployeeID")
        String = $global:uiElements["SearchInputTextBox"].Text.Trim()
        FilterSearch = $false
    }
    $selectedUser = Get-SelectedUser $Arguments

    if ($selectedUser) {
        Show-SelectedUserProps -User $selectedUser
    }
})

$global:uiElements["ClearUserButton"].Add_Click({
    $selectedUser = $null
    Reset-UI
})

# ==============================
# MAIN
# ==============================
Reset-UI

$executionTime = Measure-Command -Expression { 
    Write-Host "Loading local user database to optimize Active Directory query times. This may take up to 2-3 minutes. Please wait."
    
    $global:userHashTable = Initialize-UserHashTable -Properties @(
        "SamAccountName",
        "DisplayName",
        "EmployeeID"
    )
}

Write-Host "Execution time: $($executionTime.Minutes)m:$($executionTime.Seconds)s:$($executionTime.Milliseconds)ms"

# Hide console window
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();

[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);'

[Console.Window]::ShowWindow([Console.Window]::GetConsoleWindow(), 0) | Out-Null

$uiPages['MainWindow'].ShowDialog() | Out-Null