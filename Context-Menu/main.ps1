<#
.SYNOPSIS
    This script automates the process of enabling the classic Windows 10 right-click context menu by modifying registry keys.
    
.DESCRIPTION
     The "Classic Context Menu" PowerShell script facilitates the modification of registry keys to activate the classic Windows 10 
     right-click context menu. This menu style is favored by users seeking a more traditional interface experience. The script checks
     for the existence of the required registry path, creates it if absent, and stops File Explorer to apply changes effectively.
    
.PARAMETER 
   
    
.NOTES
    File Name      : Classic Context Menu.ps1
    Author         : Calvin Quint
    License        : GNU GPL
    Permission     : You are free to change and re-distribute this script as per the terms of the GPL.
    
.LINK
    GitHub Repository: https://github.com/calvin-quint/Public/tree/main/Context-Menu
    
.EMAIL
    Contact email: github@myqnet.io
    
#>


# Define the registry path and value name
$registryPath = "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"

# Check if the registry path exists
if (Test-Path -Path $registryPath) {
    Write-Host "Registry key '$registryPath' already exists."
} else {
    # Create the registry key
    $newKey = New-Item -Path $registryPath -Force -ErrorAction SilentlyContinue
    if (-not $newKey) {
        Write-Host "Failed to create registry key '$registryPath'."
        exit 1
    } else {
        Write-Host "Registry key '$registryPath' created successfully."
        # Stop File Explorer
        Stop-Process -Name explorer -Force
        if ($?) {
            Write-Host "File Explorer stopped successfully."
        } else {
            Write-Host "Failed to stop File Explorer. Exiting with code 1."
            exit 1
        }
    }
}

exit 0
