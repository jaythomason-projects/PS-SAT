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

# Import modules
$moduleFiles = Get-ChildItem -Path $moduleFolderPath -Filter *.psm1

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
# TODO: Define functions for view (convert XAML > XML, add tab items, add buttons to toolbox, add properties to view)
# TODO: Import XAML strings
# TODO: Define UI element variables

# ==============================
# CONTROL
# ==============================
# TODO: Add click events to UI elements that trigger model functions

# ==============================
# MAIN
# ==============================
