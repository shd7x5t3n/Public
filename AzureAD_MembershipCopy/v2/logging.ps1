function Test-OneDrive {
    if ($env:OneDrive -ne $null -and $env:OneDrive -ne "") {
        return $true
    } else {
        return $false
    }
}

# Function that determines the appropriate directory path for storing log files based on the presence of OneDrive. 
#It returns the path to the log directory within the user's Documents folder, accounting for OneDrive if it is available, 
#simplifying log file management in PowerShell scripts.
function Get-LogDirectory {
    if (Test-OneDrive) {
        return "$env:OneDrive\Documents\Scripts\Powershell\Logs"
    } else {
        return "$env:USERPROFILE\Documents\Scripts\Powershell\Logs"
    }
}

#Function that ensures the existence of a specified directory and log file, creating them if they don't exist. It provides error handling and logging, 
#making it a valuable utility for maintaining a structured logging environment in PowerShell scripts.
function Ensure-DirectoryAndLogFile {
    param (
        [string]$directoryPath,
        [string]$logFilePath
    )

    if (-not (Test-Path -Path $directoryPath -PathType Container)) {
        try {
            New-Item -Path $directoryPath -ItemType Directory -Force
            Write-Log "Directory created: $($directoryPath)" "INFO"
        } catch {
            Write-Host "Failed to create directory: $($directoryPath)"
            Write-Host "Error: $_"
            exit 1
        }
    }

    if (-not (Test-Path -Path $logFilePath)) {
        try {
            $null | Out-File -FilePath $logFilePath -Force
            Write-Log "Log file created: $logFilePath" "INFO"
        } catch {
            Write-Host "Failed to create log file: $logFilePath"
            Write-Host "Error: $_"
            exit 1
        }
    }
}

#Function that records log messages with timestamps and color-coded levels (INFO in Yellow and ERROR in Red), displaying them in the console and appending them to a log file. 
#It also manages log file size by performing log rotation when it exceeds a defined limit, ensuring effective logging and file management in PowerShell scripts.
function Write-Log {
    param(
        [string]$message,
        [string]$level
    )

    $logDirectory = Get-LogDirectory
    $logFilePath = "$logDirectory\AzureAD_MembershipCopy_Log.txt"

    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $logMessage = "[$timestamp] [$level] $message"

    # Define colors for INFO and ERROR log levels
    $infoColor = "Yellow"
    $errorColor = "Red"

    # Display the log message in the console with the appropriate color
    if ($level -eq "INFO") {
        Write-Host $logMessage -ForegroundColor $infoColor
    } elseif ($level -eq "ERROR") {
        Write-Host $logMessage -ForegroundColor $errorColor
    } else {
        Write-Host $logMessage
    }

    # Ensure the log directory and log file exist using the combined function
    Ensure-DirectoryAndLogFile -directoryPath $logDirectory -logFilePath $logFilePath

    # Append the log message to the log file
    $logMessage | Out-File -FilePath $logFilePath -Append

    # Get the current log file size
    $currentFileSize = (Get-Item $logFilePath).Length

    # Define the maximum log file size (100MB)
    $maxLogSize = 100MB

    # If the current log file size exceeds the maximum, perform log rotation
    if ($currentFileSize -gt $maxLogSize) {
        $linesToKeep = 500  # Define the maximum number of log lines to keep
        $logContent = Get-Content -Path $logFilePath -TotalCount $linesToKeep
        $logContent | Out-File -FilePath $logFilePath -Force
    }
}
