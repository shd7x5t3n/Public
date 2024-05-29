# Set the MSI product code for the version to uninstall
$MSIProductCode = '{23170F69-40C1-2702-2301-000001000000}'

Write-Output "Uninstalling 7-Zip version with product code $MSIProductCode..."

# Define the uninstallation command
$UninstallCommand = "/x $MSIProductCode /qn"

# Attempt to uninstall 7-Zip
try {
    $process = Start-Process -FilePath "msiexec.exe" -ArgumentList $UninstallCommand -PassThru -Wait -NoNewWindow
    $exitCode = $process.ExitCode

    if ($exitCode -eq 0) {
        Write-Output "7-Zip has been uninstalled successfully."
        exit 0  # Exit with success code
    } else {
        Write-Output "Failed to uninstall 7-Zip. Exit code: $exitCode"
        exit 1  # Exit with failure code
    }
} catch {
    Write-Output "An error occurred: $_"
    exit 1  # Exit with failure code
}
