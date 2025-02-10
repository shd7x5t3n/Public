# Set the minimum version required for Azul JDK
$MinimumVersion = '23.32.11'

# Define the name of the Azul JDK installer file
$InstallerFile = "zulu23.32.11-ca-jdk23.0.2-win_x64.msi"

# Get the current directory
$CurrentDirectory = Get-Location

# Check if the installer exists in the current directory
$InstallerPath = "$CurrentDirectory\$InstallerFile"
if (-Not (Test-Path -Path $InstallerPath)) {
    Write-Output "Azul JDK installer not found in the current directory: $CurrentDirectory"
    exit 1  # Exit with failure code
}

# Define the registry path where Azul JDK information is stored
$registryPath = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'

try {
    # Query the registry for information about Azul JDK
    $AzulJDKList = Get-ItemProperty -Path $registryPath | Where-Object { $_.DisplayName -like '*Azul Zulu JDK*' }

    # Initialize the flag indicating the need for installation
    $NeedInstallation = $true

    # If Azul JDK is found
    if ($AzulJDKList) {
        foreach ($AzulJDK in $AzulJDKList) {
            # Retrieve the version of the installed Azul JDK
            $VersionString = $AzulJDK.DisplayVersion
            [version]$Version = $AzulJDK.DisplayVersion
            Write-Output "Azul JDK detected. Version: $VersionString"
            
            # Extract the IdentifyingNumber from ModifyPath and set it to $AzulJDKProductCode
            $AzulJDKProductCode = $AzulJDK.ModifyPath -replace '^.*?(\{[A-F0-9\-]+\}).*$', '$1'
            
            # Compare the version with the minimum required version
            if ($Version -lt [version]$MinimumVersion) {
                Write-Output "Uninstalling Azul JDK version $VersionString..."
                
                # Define the uninstallation arguments
                $UninstallArguments = "/x `"$AzulJDKProductCode`" /qn"
                
                # Attempt to uninstall Azul JDK
                $process = Start-Process -FilePath "msiexec.exe" -ArgumentList $UninstallArguments -PassThru -Wait -NoNewWindow
                
                # Check if uninstallation was successful
                if ($process.ExitCode -eq 0) {
                    Write-Output "Azul JDK version $VersionString has been uninstalled."
                } else {
                    Write-Output "Failed to uninstall Azul JDK. Exit code: $($process.ExitCode)"
                    exit 1  # Exit with failure code
                }
            } else {
                Write-Output "Azul JDK version meets the minimum requirement. No uninstallation needed."
                $NeedInstallation = $false
            }
        }
    } else {
        Write-Output "Azul JDK is not installed. Proceeding with installation..."
    }

    # Install Azul JDK if necessary
    if ($NeedInstallation) {
        # Define the installation arguments
        $InstallArguments = "/i `"$InstallerPath`" /qn"
        Write-Output "Installing Azul JDK from $InstallerPath..."

        # Attempt to install Azul JDK
        $process = Start-Process -FilePath "msiexec.exe" -ArgumentList $InstallArguments -PassThru -Wait -NoNewWindow

        # Check if installation was successful
        if ($process.ExitCode -eq 0) {
            Write-Output "Azul JDK has been installed successfully."
            exit 0  # Exit with success code
        } else {
            Write-Output "Failed to install Azul JDK. Exit code: $($process.ExitCode)"
            exit 1  # Exit with failure code
        }
    } else {
        exit 0  # Exit with success code since no installation or uninstallation was needed
    }
} catch {
    Write-Output "An error occurred: $_"
    exit 1  # Exit with failure code
}
