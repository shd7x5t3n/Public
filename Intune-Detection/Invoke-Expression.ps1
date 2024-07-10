# Set the minimum version required for 7-Zip
$MinimumVersion = '23.01.00.0'

# Define the registry path where 7-Zip information is stored
$registryPath = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'

# Query the registry for information about 7-Zip
$7Zip = Get-ItemProperty -Path $registryPath | Where-Object { $_.DisplayName -like '*7-Zip*' }

# If 7-Zip is found
if ($7Zip) {
    # Retrieve the version of the installed 7-Zip
    $Version = $7Zip.DisplayVersion
    Write-Output "7-Zip detected. Version: $Version"
    
    # Extract the IdentifyingNumber from ModifyPath and set it to $7ZipProductCode
    $7ZipProductCode = $7Zip.ModifyPath -replace '^.*?(\{[A-F0-9\-]+\}).*$', '$1'
    
    # Compare the version with the minimum required version
    if ($Version -lt $MinimumVersion) {
        Write-Output "Uninstalling 7-Zip version $Version..."
        
        # Define the uninstallation command
        $UninstallCommand = "msiexec /x `"$($7ZipProductCode)`" /qn"
        
        # Attempt to uninstall 7-Zip
        $uninstallResult = Invoke-Expression -Command $UninstallCommand
        
        # Check  ion was successful
        if ($LASTEXITCODE -eq 0) {
            Write-Output "7-Zip version $Version has been uninstalled."
            exit 0  # Exit with success code
            $LASTEXITCODE = 0
        } else {
            Write-Output "Failed to uninstall 7-Zip. Exit code: $LASTEXITCODE"
            exit 1  # Exit with failure code
            $LASTEXITCODE = 1
        }
    } else {
        Write-Output "No action required. 7-Zip version meets minimum requirement."
        exit 0  # Exit with success code
        $LASTEXITCODE = 0
    }
} else {
    # If 7-Zip is not found
    Write-Output "7-Zip is not installed."
    exit 1  # Exit with failure code
    $LASTEXITCODE = 1
}
