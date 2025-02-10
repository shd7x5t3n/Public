# Define the minimum version to uninstall
$MinimumVersion = '23.32.11'

# Define the registry path where Azul JDK information is stored
$registryPath = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'

try {
    # Query the registry for information about Azul JDK
    $AzulJDK = Get-ItemProperty -Path $registryPath | Where-Object { $_.DisplayName -like '*Azul Zulu JDK*'}

    # If Azul JDK is found
    if ($AzulJDK) {
        # Retrieve the version of the installed Azul JDK
        $Version = $AzulJDK.DisplayVersion
        Write-Output "Azul JDK detected. Version: $Version"

        # Extract the IdentifyingNumber from ModifyPath and set it to $AzulJDKProductCode
        $AzulJDKProductCode = $AzulJDK.ModifyPath -replace '^.*?(\{[A-F0-9\-]+\}).*$', '$1'
        Write-Output "Uninstalling Azul JDK version with product code $AzulJDKProductCode..."

        # Define the uninstallation command
        $UninstallCommand = "/x `"$($AzulJDKProductCode)`" /qn"

        # Attempt to uninstall Azul JDK
        $process = Start-Process -FilePath "msiexec.exe" -ArgumentList $UninstallCommand -PassThru -Wait -NoNewWindow

        if ($process.ExitCode -eq 0) {
            Write-Output "Azul JDK has been uninstalled successfully."
            exit 0  # Exit with success code
        } else {
            Write-Output "Failed to uninstall Azul JDK. Exit code: $($process.ExitCode)"
            exit 1  # Exit with failure code
        }
    } else {
        Write-Output "Azul JDK version $MinimumVersion not found. No action taken."
        exit 0  # Exit with success code since there was nothing to uninstall
    }
} catch {
    Write-Output "An error occurred: $_"
    exit 1  # Exit with failure code
}
