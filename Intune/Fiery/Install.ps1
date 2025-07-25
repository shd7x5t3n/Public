# Variables
$downloadUrl = "https://d1umxs9ckzarso.cloudfront.net/Products/CWSP/68/DCenter/466_May/CWSPackage6_8.exe"
$fileName = "CWSPackage6_8.exe"
$workingDirectory = "C:\Temp"
$downloadLocation = Join-Path $workingDirectory $fileName
$cwsInstall = Join-Path $workingDirectory "CWSPackage68\Windows_User_SW\Fiery User Software Installer\setup.exe"

function Write-Log {
    param([string]$message)
    Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $message"
}

function Download-Installer {
    param (
        [string]$url,
        [string]$destination,
        [int]$retryCount = 3
    )

    $attempt = 0
    $success = $false

    while ($attempt -lt $retryCount -and -not $success) {
        try {
            Write-Log "Downloading installer (Attempt $($attempt + 1))..."
            Invoke-WebRequest -Uri $url -OutFile $destination -UseBasicParsing -ErrorAction Stop
            $success = $true
            Write-Log "Download completed successfully."
        }
        catch {
            Write-Log "Download failed: $_. Retrying in 5 seconds..."
            $attempt++
            Start-Sleep -Seconds 5
        }
    }

    if (-not $success) {
        throw "Failed to download installer after $retryCount attempts."
    }
}

function Extract-Installer {
    param (
        [string]$installerPath,
        [string]$extractTo
    )
    Write-Log "Extracting installer silently..."
    $proc = Start-Process -FilePath $installerPath -ArgumentList "/s" -WorkingDirectory $extractTo -Wait -PassThru
    if ($proc.ExitCode -ne 0) {
        throw "Extraction failed with exit code $($proc.ExitCode)."
    }
    Write-Log "Extraction completed."
}

function Install-Software {
    param (
        [string]$setupExePath
    )
    Write-Log "Starting software installation..."
    $arguments = "/hide_progress /clone_wait SILENT /NORBTDLG"
    $proc = Start-Process -FilePath $setupExePath -ArgumentList $arguments -Wait -PassThru
    if ($proc.ExitCode -ne 0) {
        throw "Installation failed with exit code $($proc.ExitCode)."
    }
    Write-Log "Installation completed successfully."
}

function Cleanup {
    param (
        [string]$fileToRemove,
        [string]$folderToRemove
    )

    try {
        if (Test-Path $fileToRemove) {
            Write-Log "Removing downloaded file $fileToRemove"
            Remove-Item -Path $fileToRemove -Force
        }

        if (Test-Path $folderToRemove) {
            Write-Log "Removing extracted folder $folderToRemove"
            Remove-Item -Path $folderToRemove -Recurse -Force
        }
    }
    catch {
        Write-Log "Cleanup encountered an error: $_"
    }
}

# Main script execution

try {
    # Ensure working directory exists
    if (-not (Test-Path $workingDirectory)) {
        Write-Log "Creating working directory $workingDirectory"
        New-Item -ItemType Directory -Path $workingDirectory | Out-Null
    }

    Download-Installer -url $downloadUrl -destination $downloadLocation
    Extract-Installer -installerPath $downloadLocation -extractTo $workingDirectory
    Install-Software -setupExePath $cwsInstall
}
catch {
    Write-Log "ERROR: $_"
    exit 1
}
finally {
    Cleanup -fileToRemove $downloadLocation -folderToRemove (Join-Path $workingDirectory "CWSPackage68")
}
