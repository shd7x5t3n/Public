# Set the registry path for installed applications (64-bit)
$ssmsRegistryPath64 = 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'

# Define the minimum required SSMS version
$minimumVersion = [Version]"20.7.30.0"

# Check if SSMS is installed and get its version
$ssmsInstalled = Get-ItemProperty -Path $ssmsRegistryPath64 -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName -like 'SQL Server Management Studio' }

if ($ssmsInstalled) {
    $installedVersion = [Version]($ssmsInstalled.DisplayVersion -as [string])
    if ($installedVersion -ge $minimumVersion) {
        Write-Output "SSMS version is up-to-date. Exiting..."
        exit 0
    }
    Write-Output "SSMS version is outdated. Proceeding with uninstall and reinstallation..."
} else {
    Write-Output "SSMS not found. Proceeding with installation..."
}

# Locate the SSMS-Setup-ENU.exe in Package Cache
$packageCachePath = "C:\ProgramData\Package Cache"
$ssmsSetupPath = Get-ChildItem -Path $packageCachePath -Recurse -Filter "SSMS-Setup-ENU.exe" -ErrorAction SilentlyContinue |
    Select-Object -First 1

if ($ssmsSetupPath) {
    Write-Host "Found SSMS-Setup-ENU.exe at: $($ssmsSetupPath.FullName)"
    $process = Start-Process -FilePath $ssmsSetupPath.FullName -ArgumentList "/uninstall /quiet /norestart" -Wait -PassThru
    Write-Host "Uninstall process completed with exit code: $($process.ExitCode)"
    if ($process.ExitCode -ne 0) {
        Write-Host "Uninstall failed. Exiting."
        exit 1
    }
} else {
    Write-Host "SSMS-Setup-ENU.exe not found in Package Cache."
}

# Define the URL and installation path for SSMS setup
$installUrl = 'https://aka.ms/ssmsfullsetup'
$installerPath = "$env:TEMP\SSMS_Setup.exe"
$params = "/Install /Quiet /norestart"

# Download SSMS installer
try {
    Write-Host "Downloading SSMS setup from $installUrl..."
    Invoke-WebRequest -Uri $installUrl -OutFile $installerPath -ErrorAction Stop
    Write-Host "Download complete."
} catch {
    Write-Error "Error downloading SSMS setup: $_"
    exit 1
}

# Install SSMS silently
try {
    Write-Host "Starting SSMS installation..."
    $process = Start-Process -FilePath $installerPath -ArgumentList $params -Wait -PassThru
    if ($process.ExitCode -ne 0) {
        Write-Error "SSMS installation failed with exit code $($process.ExitCode). Check logs in %TEMP%\SSMSSetup."
        exit 1
    }
    Write-Host "SSMS installation completed successfully."
    
    # Cleanup installer
    if (Test-Path $installerPath) {
        Remove-Item -Path $installerPath -Force -ErrorAction SilentlyContinue
        Write-Host "Installer removed successfully."
    }
    exit 0
} catch {
    Write-Error "Error during SSMS installation: $_"
    exit 1
}
