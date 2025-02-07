# Path to the Windows Program Directory
$programPath = [System.Environment]::GetFolderPath('ProgramFiles')

# Target Path for Salesforce Dataloader
$dataloaderPath = Join-Path -Path $programPath -ChildPath 'Salesforce Dataloader'

# Path to the dataloader.bat
$dataloaderBatPath = Join-Path -Path $dataloaderPath -ChildPath 'v58.0.4\dataloader.bat'

# Target path for the Start Menu
$startMenuPath = [System.Environment]::GetFolderPath('CommonStartMenu')

# Name of the Shortcut
$shortcutName = 'Salesforce Dataloader v58.0.4'

# Path for the shortcut in the Start Menu
$shortcutPath = Join-Path -Path $startMenuPath -ChildPath ('Programs\Salesforce Dataloader\' + $shortcutName + '.lnk')

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

# Delete the shortcut if it exists
if (Test-Path -Path $shortcutPath) {
    try {
        Remove-Item -Path $shortcutPath -Force
    }
    catch {
        Write-Host "Error: Could not delete the shortcut. Exiting with code 2."
        exit 2
    }
}

# Delete the folder if it exists
if (Test-Path -Path $dataloaderPath) {
    try {
        Remove-Item -Path $dataloaderPath -Force -Recurse
    }
    catch {
        Write-Host "Error: Could not delete the folder. Exiting with code 3."
        exit 3
    }
}

Write-Host "Salesforce Dataloader v58.0.4 uninstallation completed successfully."
exit 0
