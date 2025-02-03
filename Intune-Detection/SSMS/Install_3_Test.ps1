# Set the minimum version required for SSMS
$MinimumVersion = [Version]"20.2.30.0"

# Define the SSMS installer file name
$InstallerFile = "SSMS-Setup-ENU.exe"
$PackageCachePath = "C:\ProgramData\Package Cache"  # Update with your actual Package Cache path if necessary

# Get the current directory
$CurrentDirectory = Get-Location

# Check if the installer exists in the current directory
$InstallerPath = "$CurrentDirectory\$InstallerFile"
if (-Not (Test-Path -Path $InstallerPath)) {
    Write-Output "SSMS installer not found in the current directory: $CurrentDirectory"
    exit 1  # Exit with failure code
}

# Define the registry path where SSMS information is stored for 64-bit systems
$ssmsRegistryPath64 = 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'

# Query the registry for information about SSMS
$ssmsInstalled = Get-ItemProperty -Path $ssmsRegistryPath64 -ErrorAction SilentlyContinue | 
    Where-Object { $_.DisplayName -like 'SQL Server Management Studio' }

# Initialize the flag indicating the need for installation
$NeedInstallation = $true

# If SSMS is installed
if ($ssmsInstalled) {
    foreach ($ssms in $ssmsInstalled) {
        # Retrieve the version of the installed SSMS
        $VersionString = $ssms.DisplayVersion
        [version]$Version = $VersionString
        Write-Output "SSMS detected. Version: $VersionString"
        
        # Compare the version with the minimum required version
        if ($Version -ge $MinimumVersion) {
            Write-Output "SSMS version meets the minimum requirement. No installation needed."
            $NeedInstallation = $false
        } else {
            Write-Output "SSMS version is older than the required version ($MinimumVersion). Uninstalling older version..."
            
            # Look for SSMS setup file in the Package Cache for uninstallation
             $ssmsSetupPath = Get-ChildItem -Path $packageCachePath -Recurse -Filter "SSMS-Setup-ENU.exe" -ErrorAction SilentlyContinue

            # Check if the SSMS setup executable exists
            if ($ssmsSetupPath) {
                Write-Host "Found SSMS-Setup-ENU.exe at: $($ssmsSetupPath.FullName)"
                
                # Uninstall SSMS using the setup file with the '/uninstall' argument
                $process = Start-Process $ssmsSetupPath.FullName -ArgumentList "/uninstall /quiet /norestart" -Wait -PassThru

                # Output the result of the process execution
                Write-Host "Uninstall process completed with exit code: $($process.ExitCode)"
                
                # Exit based on the process exit code
                if ($process.ExitCode -eq 0) {
                    Write-Host "Uninstall successful. Proceeding with installation of the latest version."
                } else {
                    Write-Host "Uninstall failed with exit code: $($process.ExitCode)"
                    exit 1  # Exit if uninstall fails
                }
            } else {
                Write-Host "SSMS-Setup-ENU.exe not found in Package Cache."
                exit 1  # Exit if SSMS-Setup-ENU.exe is not found
            }
        }
    }
} else {
    Write-Output "SSMS is not installed. Proceeding with installation..."
}

# Install SSMS if necessary
if ($NeedInstallation) {
    # Install SSMS silently without UI interaction
    try {
        Write-Output "Starting SSMS installation..."
        $process = Start-Process "$InstallerPath" -ArgumentList "/install /quiet /norestart" -Wait -PassThru

        # Check if the installation was successful based on the exit code
        if ($process.ExitCode -eq 0) {
            Write-Output "SSMS installation completed successfully."
            exit 0  # Exit with success code
        } else {
            Write-Output "SSMS installation failed with exit code $($process.ExitCode)."
            exit 1  # Exit if installation fails
        }
    } catch {
        Write-Output "Error during SSMS installation: $_"
        exit 1  # Exit if any error occurs during installation
    }
} else {
    exit 0  # Exit with success code since no installation or uninstallation was needed
}
