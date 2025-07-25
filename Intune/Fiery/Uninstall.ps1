# Set the path to the InstallShield Installation Information directory
$installShieldPath = "C:\Program Files (x86)\InstallShield Installation Information"

# Locate the setup.exe file associated with Fiery Command WorkStation
$setupFile = Get-ChildItem -Path $installShieldPath -Recurse -Filter "setup.exe" -ErrorAction SilentlyContinue

# Check if the file was found
if ($setupFile) {
    Write-Host "Found setup.exe at: $($setupFile.FullName)"
    
    # Uninstall Fiery Command WorkStation using Start-Process with the '/removeonly' argument
    $process = Start-Process $setupFile.FullName -ArgumentList "-runfromtemp -l0x0409 remove -removeonly /quiet /norestart" -Wait -PassThru

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
    Write-Host "setup.exe not found in InstallShield Installation Information."
    exit 1
}
