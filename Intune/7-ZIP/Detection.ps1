# Set the minimum version required for 7-Zip
$MinimumVersion = '24.07.00.0'

# Define the registry path where 7-Zip information is stored
$registryPath = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'

try {
    # Query the registry for information about 7-Zip
    $7ZipList = Get-ItemProperty -Path $registryPath | Where-Object { $_.DisplayName -like '*7-Zip*' }

    # If 7-Zip is found
    if ($7ZipList) {
        foreach ($7Zip in $7ZipList) {
            # Retrieve the version of the installed 7-Zip
            $VersionString = $7Zip.DisplayVersion
            [version]$Version = $7Zip.DisplayVersion
            Write-Output "7-Zip detected. Version: $VersionString"
            
            # Compare the version with the minimum required version
            if ($Version -lt $MinimumVersion) {
                Write-Output "7-Zip version $VersionString does not meet the minimum requirement."
                exit 1  # Exit with failure code
            } else {
                Write-Output "7-Zip version meets the minimum requirement."
                exit 0  # Exit with success code
            }
        }
    } else {
        Write-Output "7-Zip is not installed."
        exit 1  # Exit with failure code
    }
} catch {
    Write-Output "An error occurred: $_"
    exit 1  # Exit with failure code
}
