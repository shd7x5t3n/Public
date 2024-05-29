# Define the name of the 7-Zip installer file
$InstallerFile = "7z1900-x64.msi"

# Get the current directory
$CurrentDirectory = Get-Location

# Check if the installer exists in the current directory
$InstallerPath = "$CurrentDirectory\$InstallerFile"
if (-Not (Test-Path -Path $InstallerPath)) {
    Write-Output "7-Zip installer not found in the current directory: $CurrentDirectory"
    exit 1  # Exit with failure code
}

# Define the installation arguments
$InstallArguments = "/i `"$InstallerPath`" /qn"

Write-Output "Installing 7-Zip from $InstallerPath..."

# Attempt to install 7-Zip
$process = Start-Process -FilePath msiexec.exe -ArgumentList $InstallArguments -PassThru -Wait

# Check if installation was successful
if ($process.ExitCode -eq 0) {
    Write-Output "7-Zip has been installed successfully."
    exit 0  # Exit with success code
} else {
    Write-Output "Failed to install 7-Zip. Exit code: $($process.ExitCode)"
    exit 1  # Exit with failure code
}
