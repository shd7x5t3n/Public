<# 
.SYNOPSIS 
Detect and Remove Classic Microsoft Teams
.DESCRIPTION 
This script detects if the new Microsoft Teams app is installed and then removes the classic Teams app and machine-wide installer.
.NOTES     
    Name        : Remove-ClassicTeams.ps1
    Author      : Jatin Makhija
    Version     : 1.0.0
    DateCreated : 12-Jan-2024
    Blog        : https://cloudinfra.net
#>

# Define the path where New Microsoft Teams is installed
$teamsPath = "C:\Program Files\WindowsApps"

# Define the filter pattern for Microsoft Teams installer
$teamsInstallerName = "MSTeams_*"

# Retrieve items in the specified path matching the filter pattern
$teamsNew = Get-ChildItem -Path $teamsPath -Filter $teamsInstallerName

# Check if New Microsoft Teams is installed
if ($teamsNew) {
    Write-Host "New Microsoft Teams client is installed."

    # Define path to the Teams bootstrapper
    $bootstrapperPath = "C:\Program Files (x86)\Teams Installer\Update.exe"

    # Check if the bootstrapper exists
    if (Test-Path $bootstrapperPath) {
        # Uninstall classic Teams using the bootstrapper
        & $bootstrapperPath --uninstall -s
        Write-Host "Classic Microsoft Teams removed."
        exit 0
    } else {
        Write-Host "Error: Teams bootstrapper not found."
        exit 1
    }
} else {
    Write-Host "Microsoft Teams client not found."
    exit 1
}
