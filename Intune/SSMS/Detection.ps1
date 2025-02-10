# Set the minimum version required for SSMS
$MinimumVersion = '20.2.30.0'  # Adjust this to the version you want to require

# Define the registry path where SSMS information is stored (64-bit registry path)
$ssmsRegistryPath64 = 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'

try {
    # Query the registry for information about SQL Server Management Studio
    $ssmsList = Get-ItemProperty -Path $ssmsRegistryPath64 -ErrorAction SilentlyContinue | 
                Where-Object { $_.DisplayName -like 'SQL Server Management Studio' }

    # If SSMS is found
    if ($ssmsList) {
        foreach ($ssms in $ssmsList) {
            # Retrieve the version of the installed SSMS
            $VersionString = $ssms.DisplayVersion
            [version]$Version = $ssms.DisplayVersion
            Write-Output "SSMS detected. Version: $VersionString"
            
            # Compare the version with the minimum required version
            if ($Version -lt [version]$MinimumVersion) {
                Write-Output "SSMS version $VersionString does not meet the minimum requirement."
                exit 1  # Exit with failure code if version is lower than required
            } else {
                Write-Output "SSMS version meets the minimum requirement."
                exit 0  # Exit with success code if version is correct or higher
            }
        }
    } else {
        Write-Output "SSMS is not installed."
        exit 1  # Exit with failure code if SSMS is not found
    }
} catch {
    Write-Output "An error occurred: $_"
    exit 1  # Exit with failure code if an error occurs
}
