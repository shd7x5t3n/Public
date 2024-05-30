# Define the minimum version to uninstall
$MinimumVersion = '23.01.00.0'

# Define the registry path where 7-Zip information is stored
$registryPath = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'

try {
    # Query the registry for information about 7-Zip
    $7Zip = Get-ItemProperty -Path $registryPath | Where-Object { $_.DisplayName -like '*7-Zip*' -and $_.DisplayVersion -eq $MinimumVersion }

    # If 7-Zip is found
    if ($7Zip) {
        # Retrieve the version of the installed 7-Zip
        $Version = $7Zip.DisplayVersion
        Write-Output "7-Zip detected. Version: $Version"

        # Extract the IdentifyingNumber from ModifyPath and set it to $7ZipProductCode
        $7ZipProductCode = $7Zip.ModifyPath -replace '^.*?(\{[A-F0-9\-]+\}).*$', '$1'
        Write-Output "Uninstalling 7-Zip version with product code $7ZipProductCode..."

        # Define the uninstallation command
        $UninstallCommand = "/x `"$($7ZipProductCode)`" /qn"

        # Attempt to uninstall 7-Zip
        $process = Start-Process -FilePath "msiexec.exe" -ArgumentList $UninstallCommand -PassThru -Wait -NoNewWindow

        if ($process.ExitCode -eq 0) {
            Write-Output "7-Zip has been uninstalled successfully."
            exit 0  # Exit with success code
        } else {
            Write-Output "Failed to uninstall 7-Zip. Exit code: $($process.ExitCode)"
            exit 1  # Exit with failure code
        }
    } else {
        Write-Output "7-Zip version $MinimumVersion not found. No action taken."
        exit 0  # Exit with success code since there was nothing to uninstall
    }
} catch {
    Write-Output "An error occurred: $_"
    exit 1  # Exit with failure code
}
