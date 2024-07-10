# Set the minimum version required for 7-Zip
$MinimumVersion = '24.07.00.0'

# Define the registry path where 7-Zip information is stored
$registryPath = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'

# Query the registry for information about 7-Zip
try {
    $7ZipItems = Get-ItemProperty -Path $registryPath | Where-Object { $_.DisplayName -like '*7-Zip*' }
} catch {
    Write-Output "Failed to query the registry. Error: $_"
    exit 1
}

# If 7-Zip is found
if ($7ZipItems) {
    foreach ($7Zip in $7ZipItems) {
        # Retrieve the version of the installed 7-Zip
        try {
            $Version = $7Zip.DisplayVersion
            Write-Output "7-Zip detected. Version: $Version"
        } catch {
            Write-Output "Error retrieving version for 7-Zip entry. Error: $_"
            continue
        }

        # Extract the IdentifyingNumber from ModifyPath and set it to $7ZipProductCode
        try {
            $7ZipProductCode = $7Zip.ModifyPath -replace '^.*?(\{[A-F0-9\-]+\}).*$', '$1'
        } catch {
            Write-Output "Failed to extract product code from ModifyPath. Error: $_"
            continue
        }
        
        # Compare the version with the minimum required version
        if ([version]$Version -lt [version]$MinimumVersion) {
            Write-Output "Uninstalling 7-Zip version $Version..."
            
            # Define the uninstallation command with logging
            $UninstallCommand = "/x $($7ZipProductCode) /qn /l*v `"$env:TEMP\7Zip_Uninstall.log`""
            
            # Attempt to uninstall 7-Zip
            try {
                $process = Start-Process -FilePath msiexec.exe -ArgumentList $UninstallCommand -PassThru -Wait -WindowStyle Hidden

                # Check if uninstallation was successful
                if ($process.ExitCode -eq 0) {
                    Write-Output "7-Zip version $Version has been uninstalled."
                    exit 0  # Exit with success code
                } else {
                    Write-Output "Failed to uninstall 7-Zip. Exit code: $($process.ExitCode)"
                    Write-Output "Check the log file at $env:TEMP\7Zip_Uninstall.log for more details."
                    exit 1  # Exit with failure code
                }
            } catch {
                Write-Output "Failed to start the uninstallation process. Error: $_"
                exit 1
            }
        } else {
            Write-Output "No action required. 7-Zip version meets minimum requirement."
            exit 0  # Exit with success code
        }
    }
} else {
    # If 7-Zip is not found
    Write-Output "7-Zip is not installed."
    exit 1  # Exit with failure code
}
