# Set the minimum version required for 7-Zip
$MinimumVersion = '24.07.00.0'

# Define the registry path where 7-Zip information is stored
$registryPath = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'

# Query the registry for information about 7-Zip
try {
    $7ZipItems = Get-ItemProperty -Path $registryPath | Where-Object { $_.DisplayName -like '*7-Zip*' }
} catch {
    exit 1
}

# If 7-Zip is found
if ($7ZipItems) {
    foreach ($7Zip in $7ZipItems) {
        # Retrieve the version of the installed 7-Zip
        try {
            $Version = $7Zip.DisplayVersion
        } catch {
            continue
        }

        # Extract the IdentifyingNumber from ModifyPath and set it to $7ZipProductCode
        try {
            $7ZipProductCode = $7Zip.ModifyPath -replace '^.*?(\{[A-F0-9\-]+\}).*$', '$1'
        } catch {
            continue
        }
        
        # Compare the version with the minimum required version
        if ([version]$Version -lt [version]$MinimumVersion) {
            # Define the uninstallation command without logging
            $UninstallCommand = "/x $($7ZipProductCode) /qn"
            
            # Attempt to uninstall 7-Zip
            try {
                $process = Start-Process -FilePath msiexec.exe -ArgumentList $UninstallCommand -PassThru -Wait -WindowStyle Hidden

                # Check if uninstallation was successful
                if ($process.ExitCode -eq 0) {
                    exit 0  # Exit with success code
                } else {
                    exit 1  # Exit with failure code
                }
            } catch {
                exit 1
            }
        } else {
            exit 0  # Exit with success code
        }
    }
} else {
    # If 7-Zip is not found
    exit 0  # Exit with success code
}
