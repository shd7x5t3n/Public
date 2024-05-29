# Set the specific version to uninstall
$VersionToUninstall = '23.01.00.0'

# Define the registry path where 7-Zip information is stored
$registryPath = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'

# Query the registry for information about 7-Zip
$7Zip = Get-ItemProperty -Path $registryPath | Where-Object { $_.DisplayName -like '*7-Zip*' }

# If 7-Zip is found
if ($7Zip) {
    # Retrieve the version of the installed 7-Zip
    $Version = $7Zip.DisplayVersion
    Write-Output "7-Zip detected. Version: $Version"
    
    # Compare the version with the specific version to uninstall
    if ($Version -eq $VersionToUninstall) {
        # Extract the IdentifyingNumber from ModifyPath and set it to $7ZipProductCode
        $7ZipProductCode = $7Zip.ModifyPath -replace '^.*?(\{[A-F0-9\-]+\}).*$', '$1'
        
        Write-Output "Uninstalling 7-Zip version $Version..."
        
        # Define the uninstallation command
        $UninstallCommand = "msiexec /x `"$($7ZipProductCode)`" /qn"
        
        # Attempt to uninstall 7-Zip
        $uninstallResult = Invoke-Expression -Command $UninstallCommand
        
        # Check if uninstallation was successful
        if ($LASTEXITCODE -eq 0) {
            Write-Output "7-Zip version $Version has been uninstalled."
            exit 0  # Exit with success code
        } else {
            Write-Output "Failed to uninstall 7-Zip. Exit code: $LASTEXITCODE"
            exit 1  # Exit with failure code
        }
    } else {
        Write-Output "7-Zip version does not match the version to uninstall. No uninstallation needed."
        exit 0  # Exit with success code
    }
} else {
    # If 7-Zip is not found
    Write-Output "7-Zip is not installed."
    exit 0  # Exit with success code as no action is needed
}
 
