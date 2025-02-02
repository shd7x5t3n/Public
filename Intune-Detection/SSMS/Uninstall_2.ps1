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
        Write-Host "Uninstall successful."
        exit 0
    } else {
        Write-Host "Uninstall failed with exit code: $($process.ExitCode)"
        exit 1
    }
} else {
    Write-Host "SSMS-Setup-ENU.exe not found in Package Cache."
    exit 1
}
