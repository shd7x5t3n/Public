# Path to the Windows Program Directory
$programPath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::ProgramFilesX86)

# Target Path for Salesforce Dataloader
$dataloaderPath = Join-Path -Path $programPath -ChildPath 'Salesforce Dataloader\'

# Path to the install.bat
$dataloaderBatPath = Join-Path -Path $dataloaderPath -ChildPath 'install.bat'

# Target path for the Start Menu
$startMenuPath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::CommonStartMenu)

# Path to the entire Salesforce Dataloader folder in Start Menu
$startMenuFolderPath = Join-Path -Path $startMenuPath -ChildPath 'Programs\Salesforce Dataloader'

# Ensure the script is running with elevated (Administrator) rights
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    try {
        Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        exit
    }
    catch {
        Write-Host "Error: Could not elevate to administrator. Exiting with code 1."
        exit 1
    }
}

# Delete the entire Start Menu folder if it exists
if (Test-Path -Path $startMenuFolderPath) {
    try {
        Remove-Item -Path $startMenuFolderPath -Force -Recurse -ErrorAction Stop
        Write-Host "Start Menu folder deleted successfully."
    }
    catch {
        Write-Host "Error: Could not delete the Start Menu folder. $_"
        exit 1  # Intune failure exit code
    }
} else {
    Write-Host "Start Menu folder not found. Skipping removal."
}

# Delete the Salesforce Data Loader installation folder if it exists
if (Test-Path -Path $dataloaderPath) {
    try {
        Remove-Item -Path $dataloaderPath -Force -Recurse -ErrorAction Stop
        Write-Host "Salesforce Data Loader installation folder deleted successfully."
    }
    catch {
        Write-Host "Error: Could not delete the Data Loader installation folder. $_"
        exit 1  # Intune failure exit code
    }
} else {
    Write-Host "Salesforce Data Loader directory not found. Skipping removal."
}

Write-Host "Salesforce Dataloader v63.0.0 uninstallation completed successfully."
exit 0  # Intune success exit code
