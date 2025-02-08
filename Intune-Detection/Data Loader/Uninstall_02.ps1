# Path to the Windows Program Directory
$programPath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::ProgramFilesX86)

# Target Path for Salesforce Dataloader
$dataloaderPath = Join-Path -Path $programPath -ChildPath 'Salesforce Dataloader\v63.0.0'

# Path to the install.bat
$dataloaderBatPath = Join-Path -Path $dataloaderPath -ChildPath 'install.bat'

# Target path for the Start Menu
$startMenuPath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::CommonStartMenu)

# Name of the Shortcut
$shortcutName = 'Salesforce Dataloader v63.0.0'

# Path for the shortcut in the Start Menu
$shortcutPath = Join-Path -Path $startMenuPath -ChildPath ('Programs\Salesforce Dataloader\' + $shortcutName + '.lnk')

# Ensure the script is running with elevated (Administrator) rights
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Error: Script must be run as administrator."
    exit 1  # Intune failure exit code
}

# Delete the shortcut if it exists
if (Test-Path -Path $shortcutPath) {
    try {
        Remove-Item -Path $shortcutPath -Force -ErrorAction Stop
        Write-Host "Shortcut deleted successfully."
    }
    catch {
        Write-Host "Error: Could not delete the shortcut. $_"
        exit 1  # Intune failure exit code
    }
}

# Delete the Salesforce Data Loader folder if it exists
if (Test-Path -Path $dataloaderPath) {
    try {
        Remove-Item -Path $dataloaderPath -Force -Recurse -ErrorAction Stop
        Write-Host "Salesforce Data Loader folder deleted successfully."
    }
    catch {
        Write-Host "Error: Could not delete the Data Loader folder. $_"
        exit 1  # Intune failure exit code
    }
} else {
    Write-Host "Salesforce Data Loader directory not found. Skipping removal."
}

Write-Host "Salesforce Dataloader v63.0.0 uninstallation completed successfully."
exit 0  # Intune success exit code
