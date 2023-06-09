# param(
    
# )

# ==============================
# SETUP
# ==============================
# Set strict mode
Set-StrictMode -Version Latest

# Stop the script if any command fails
$ErrorActionPreference = "Stop"

# Load assemblies
$assemblies = @(
    "PresentationFramework"
    "PresentationCore"
    "WindowsBase"
    "System.Windows.Forms"
)

foreach ($assembly in $assemblies) {
    try {
        Add-Type -AssemblyName $assembly
    } catch {
        Write-Error "Failed to load assembly: $assembly. Exiting script."
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

# Import config
try {
    $config = (Get-Content -Path $configFilePath) | ConvertFrom-Json
} catch {
    Write-Error "Failed to load or parse config file. Exiting script."
    return
}

# ==============================
# MODEL
# ==============================
# TODO: Define functions for model (get user)
# TODO: Import modules (prompt for admin, load database)

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
