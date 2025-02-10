# Set the minimum version required for 7-Zip
$MinimumVersion = '24.07.00.0'

# Define the name of the 7-Zip installer file
$InstallerFile = "7z2407-x64.msi"

# Get the current directory
$CurrentDirectory = Get-Location

# Check if the installer exists in the current directory
$InstallerPath = "$CurrentDirectory\$InstallerFile"
if (-Not (Test-Path -Path $InstallerPath)) {
    Write-Output "7-Zip installer not found in the current directory: $CurrentDirectory"
    exit 1  # Exit with failure code
}

# Define the registry path where 7-Zip information is stored
$registryPath = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'

try {
    # Query the registry for information about 7-Zip
    $7ZipList = Get-ItemProperty -Path $registryPath | Where-Object { $_.DisplayName -like '*7-Zip*' }

    # Initialize the flag indicating the need for installation
    $NeedInstallation = $true

    # If 7-Zip is found
    if ($7ZipList) {
        foreach ($7Zip in $7ZipList) {
            # Retrieve the version of the installed 7-Zip
            $VersionString = $7Zip.DisplayVersion
            [version]$Version = $7Zip.DisplayVersion
            Write-Output "7-Zip detected. Version: $VersionString"
            
            # Extract the IdentifyingNumber from ModifyPath and set it to $7ZipProductCode
            $7ZipProductCode = $7Zip.ModifyPath -replace '^.*?(\{[A-F0-9\-]+\}).*$', '$1'
            
            # Compare the version with the minimum required version
            if ($Version -lt [version]$MinimumVersion) {
                Write-Output "Uninstalling 7-Zip version $VersionString..."
                
                # Define the uninstallation arguments
                $UninstallArguments = "/x `"$7ZipProductCode`" /qn"
                
                # Attempt to uninstall 7-Zip
                $process = Start-Process -FilePath "msiexec.exe" -ArgumentList $UninstallArguments -PassThru -Wait -NoNewWindow
                
                # Check if uninstallation was successful
                if ($process.ExitCode -eq 0) {
                    Write-Output "7-Zip version $VersionString has been uninstalled."
                } else {
                    Write-Output "Failed to uninstall 7-Zip. Exit code: $($process.ExitCode)"
                    exit 1  # Exit with failure code
                }
            } else {
                Write-Output "7-Zip version meets the minimum requirement. No uninstallation needed."
                $NeedInstallation = $false
            }
        }
    } else {
        Write-Output "7-Zip is not installed. Proceeding with installation..."
    }

    # Install 7-Zip if necessary
    if ($NeedInstallation) {
        # Define the installation arguments
        $InstallArguments = "/i `"$InstallerPath`" /qn"
        Write-Output "Installing 7-Zip from $InstallerPath..."

        # Attempt to install 7-Zip
        $process = Start-Process -FilePath "msiexec.exe" -ArgumentList $InstallArguments -PassThru -Wait -NoNewWindow

        # Check if installation was successful
        if ($process.ExitCode -eq 0) {
            Write-Output "7-Zip has been installed successfully."
            exit 0  # Exit with success code
        } else {
            Write-Output "Failed to install 7-Zip. Exit code: $($process.ExitCode)"
            exit 1  # Exit with failure code
        }
    } else {
        exit 0  # Exit with success code since no installation or uninstallation was needed
    }
} catch {
    Write-Output "An error occurred: $_"
    exit 1  # Exit with failure code
}
