# Enable strict error handling
$ErrorActionPreference = "Stop"

try {
    # Paths
    $programPath = ${env:ProgramFiles(x86)}
    $dataloaderPath = "$programPath\Salesforce Dataloader"
    $startMenuPath = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Salesforce Dataloader"

    # Ensure the script is running with elevated privileges
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "Script requires administrator privileges. Restarting with elevation..."
        Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        exit
    }

    # Remove Start Menu folder if it exists
    if (Test-Path $startMenuPath) {
        Remove-Item -Path $startMenuPath -Force -Recurse
        Write-Host "Start Menu folder deleted successfully."
    } else {
        Write-Host "Start Menu folder not found. Skipping removal."
    }

    # Remove Salesforce Data Loader installation folder if it exists
    if (Test-Path $dataloaderPath) {
        Remove-Item -Path $dataloaderPath -Force -Recurse
        Write-Host "Salesforce Data Loader installation folder deleted successfully."
    } else {
        Write-Host "Salesforce Data Loader directory not found. Skipping removal."
    }

    Write-Host "Salesforce Data Loader uninstallation completed successfully."
    exit 0  # Success
}
catch {
    Write-Host "Error: $($_.Exception.Message)"
    exit 1  # Failure
}
