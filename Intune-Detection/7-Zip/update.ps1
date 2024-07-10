# Define the name of the 7-Zip installer file
$InstallerFile = "7z2407-x64.msi"

# Check if the installer exists in the current directory
if (-Not (Test-Path -Path $InstallerFile)) {
    Write-Output "7-Zip installer not found in the current directory."
    exit 1  # Exit with failure code
}

# Define the installation arguments
$InstallArguments = "/i `"$InstallerFile`" /qn"

Write-Output "Installing 7-Zip from $InstallerFile..."

# Attempt to install 7-Zip
$process = Start-Process -FilePath msiexec.exe -ArgumentList $InstallArguments -PassThru -Wait

# Check if the installation was successful
if ($process.ExitCode -eq 0) {
    Write-Output "7-Zip has been installed successfully."
    exit 0  # Exit with success code
} else {
    Write-Output "Failed to install 7-Zip. Exit code: $($process.ExitCode)"
    exit 1  # Exit with failure code
}
