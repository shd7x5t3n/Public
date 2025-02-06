# Define the log file path
$logFilePath = "C:\ProgramData\Microsoft\IntuneManagementExtension\ssms.log"

# Start logging to the log file
Start-Transcript -Path $logFilePath -Append

# Set the registry path for installed applications (64-bit)
$ssmsRegistryPath64 = 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'

# Define the minimum required SSMS version
$minimumVersion = [Version]"20.2.30.0"

Write-Output "Checking if SSMS is installed..."

# Check if SSMS is installed and get its version
$ssmsInstalled = Get-ItemProperty -Path $ssmsRegistryPath64 -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName -like 'SQL Server Management Studio' }

if ($ssmsInstalled) {
    $installedVersion = [Version]($ssmsInstalled.DisplayVersion -as [string])
    Write-Output "SSMS is installed. Version: $installedVersion"
    if ($installedVersion -ge $minimumVersion) {
        Write-Output "SSMS version is up-to-date. Exiting..."
        exit 0  # No installation needed
    }
    Write-Output "SSMS version is outdated. Proceeding with uninstallation and reinstallation..."
} else {
    Write-Output "SSMS not found. Proceeding with installation..."
}

# Locate the SSMS-Setup-ENU.exe in Package Cache
$packageCachePath = "C:\ProgramData\Package Cache"
$ssmsSetupPath = Get-ChildItem -Path $packageCachePath -Recurse -Filter "SSMS-Setup-ENU.exe" -ErrorAction SilentlyContinue |
    Select-Object -First 1

if ($ssmsSetupPath) {
    Write-Output "Found SSMS-Setup-ENU.exe at: $($ssmsSetupPath.FullName)"
    try {
        # Uninstall SSMS
        Write-Output "Starting SSMS uninstall..."
        $process = Start-Process -FilePath $ssmsSetupPath.FullName -ArgumentList "/uninstall /quiet /norestart" -Wait -PassThru
        Write-Output "Uninstall process completed with exit code: $($process.ExitCode)"
        
        if ($process.ExitCode -ne 0) {
            Write-Error "Uninstall failed with exit code: $($process.ExitCode). Exiting."
            exit 1
        }
    } catch {
        Write-Error "Error during SSMS uninstall: $_"
        exit 1
    }
} else {
    Write-Output "SSMS-Setup-ENU.exe not found in Package Cache."
}

# Define the URL and installation path for SSMS setup
$installUrl = 'https://aka.ms/ssmsfullsetup'
$installerPath = "$env:TEMP\SSMS_Setup.exe"
$params = "/Install /Quiet /norestart"

Write-Output "Downloading SSMS setup from $installUrl..."

# Download SSMS installer with retry logic
$retryCount = 3
$attempt = 0
$downloadSuccess = $false

while ($attempt -lt $retryCount -and !$downloadSuccess) {
    try {
        Invoke-WebRequest -Uri $installUrl -OutFile $installerPath -ErrorAction Stop
        Write-Output "Download complete."
        $downloadSuccess = $true
    } catch {
        Write-Error "Error downloading SSMS setup: $_. Attempt $($attempt + 1) of $retryCount."
        $attempt++
        if ($attempt -eq $retryCount) {
            exit 1  # Exit after retry attempts are exhausted
        }
        Start-Sleep -Seconds 10  # Retry after a short delay
    }
}

# Install SSMS silently
try {
    Write-Output "Starting SSMS installation..."
    $process = Start-Process -FilePath $installerPath -ArgumentList $params -Wait -PassThru
    
    # Check the exit code of the installation
    if ($process.ExitCode -eq 0) {
        Write-Output "SSMS installation completed successfully."
    } else {
        Write-Error "SSMS installation failed with exit code $($process.ExitCode). Check logs in %TEMP%\SSMSSetup."
        exit 1
    }
    
    # Cleanup installer
    if (Test-Path $installerPath) {
        Remove-Item -Path $installerPath -Force -ErrorAction SilentlyContinue
        Write-Output "Installer removed successfully."
    }

    exit 0  # Success exit code
} catch {
    Write-Error "Error during SSMS installation: $_"
    exit 1
}

# Stop logging
Stop-Transcript
