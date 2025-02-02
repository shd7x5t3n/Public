# Set the registry path for installed applications (64-bit)
$ssmsRegistryPath64 = 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'

# Define the minimum required SSMS version
$minimumVersion = [Version]"20.2.30.0"

# Check if SSMS is already installed by looking for its registry entry
$ssmsInstalled = Get-ItemProperty -Path $ssmsRegistryPath64 -ErrorAction SilentlyContinue | 
    Where-Object { $_.DisplayName -like 'SQL Server Management Studio' }

# If SSMS is installed, extract its version and compare it
if ($ssmsInstalled) {
    # Extract the version as a [Version] object
    $installedVersion = [Version]$ssmsInstalled.DisplayVersion

    # Compare the installed version with the minimum required version
    if ($installedVersion -lt $minimumVersion) {
        # Version is outdated, proceed with uninstall and reinstallation
        Write-Output "SSMS version is outdated. Proceeding with uninstall and reinstallation..."
        
        # Set the path to the Package Cache directory
        $packageCachePath = "C:\ProgramData\Package Cache"

        # Locate the SSMS-Setup-ENU.exe file
        $ssmsSetupPath = Get-ChildItem -Path $packageCachePath -Recurse -Filter "SSMS-Setup-ENU.exe" -ErrorAction SilentlyContinue

        # Check if the file was found
        if ($ssmsSetupPath) {
            Write-Host "Found SSMS-Setup-ENU.exe at: $($ssmsSetupPath.FullName)"
            
            # Uninstall SSMS using Start-Process with the '/uninstall' argument
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
    } else {
        # Version meets the requirement, exit silently
        Write-Output "SSMS version is up-to-date. Exiting..."
        exit 0
    }
}

# If SSMS is not installed or the version is outdated, proceed with the installation
Write-Output "SSMS is not installed or version is outdated. Proceeding with installation..."

# Define the URL for the SSMS setup
$installurl = 'https://aka.ms/ssmsfullsetup'

# Try downloading the SSMS setup executable silently
try {
    Write-Output "Downloading SSMS setup from $installurl..."
    Invoke-WebRequest -Uri $installurl -OutFile "$env:localappdata\temp\SSMS_Setup.exe" -ErrorAction Stop
    Write-Output "Download complete."
} catch {
    Write-Output "Error downloading SSMS setup: $_"
    exit 1  # Exit if download fails
}

# Install SSMS silently without UI interaction
try {
    Write-Output "Starting SSMS installation..."
    $process = Start-Process "$env:localappdata\temp\SSMS_Setup.exe" -ArgumentList "/install /quiet /norestart" -Wait -PassThru

    # Check if the installation was successful based on the exit code
    if ($process.ExitCode -eq 0) {
        Write-Output "SSMS installation completed successfully."
        # Remove the installer and exit with success code
        Remove-Item "$env:localappdata\temp\SSMS_Setup.exe" -ErrorAction SilentlyContinue
        exit 0
    } else {
        Write-Output "SSMS installation failed with exit code $($process.ExitCode)."
        exit 1  # Exit if installation fails
    }
} catch {
    Write-Output "Error during SSMS installation: $_"
    exit 1  # Exit if any error occurs during installation
}
