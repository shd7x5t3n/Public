# Define the name of the 7-Zip installer file
$InstallerFile = "7zSetup.msi"

# Check if the installer exists in the current directory
if (-Not (Test-Path -Path $InstallerFile)) {
    Write-Output "7-Zip installer not found in the current directory: $InstallerFile"
    exit 1  # Exit with failure code
}

# Define the installation command
$InstallCommand = "msiexec /i `"$PSScriptRoot\$InstallerFile`" /qn"

Write-Output "Installing 7-Zip from $PSScriptRoot\$InstallerFile..."

# Attempt to install 7-Zip
$installResult = Invoke-Expression -Command $InstallCommand

# Check if installation was successful
if ($LASTEXITCODE -eq 0) {
    Write-Output "7-Zip has been installed successfully."
    exit 0  # Exit with success code
} else {
    Write-Output "Failed to install 7-Zip. Exit code: $LASTEXITCODE"
    exit 1  # Exit with failure code
}
