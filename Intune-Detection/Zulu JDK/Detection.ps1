# Set the minimum version required for Azul JDK
$MinimumVersion = '23.32.11'

# Define the registry path where Azul JDK information is stored
$registryPath = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'

try {
    # Query the registry for information about Azul JDK
    $AzulJDKList = Get-ItemProperty -Path $registryPath | Where-Object { $_.DisplayName -like '*Azul Zulu JDK*' }

    if ($AzulJDKList) {
        # Azul JDK is installed
        foreach ($AzulJDK in $AzulJDKList) {
            # Retrieve the version of the installed Azul JDK
            $VersionString = $AzulJDK.DisplayVersion
            [version]$Version = $AzulJDK.DisplayVersion
            Write-Output "Azul JDK detected. Version: $VersionString"
            
            # Compare the installed version with the minimum required version
            if ($Version -ge [version]$MinimumVersion) {
                Write-Output "Azul JDK version is up to date. Version: $VersionString"
                exit 0  # Exit with success code
            } else {
                Write-Output "Azul JDK version $VersionString is older than the required version ($MinimumVersion)."
                exit 1  # Exit with failure code
            }
        }
    } else {
        # Azul JDK is not installed
        Write-Output "Azul JDK is not installed."
        exit 1  # Exit with failure code
    }
} catch {
    Write-Output "An error occurred while checking for Azul JDK: $_"
    exit 1  # Exit with failure code
}
