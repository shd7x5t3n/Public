# Function to kill running Figma processes (any process with 'figma' in name)
function Stop-FigmaProcess {
    $figmaProcesses = Get-Process -Name "*figma*" -ErrorAction SilentlyContinue

    if ($figmaProcesses) {
        try {
            $figmaProcesses | Stop-Process -Force -ErrorAction Stop
        } catch {
            Write-Error "Failed to stop Figma processes: $_"
            exit 1
        }
    }
}

# Function to remove Figma installation folder with retry
function Remove-FigmaInstallation {
    $figmaPath = "$env:LOCALAPPDATA\Figma"
    $maxRetries = 5
    $retryDelaySeconds = 2

    if (-not (Test-Path $figmaPath)) {
        return
    }

    for ($i = 1; $i -le $maxRetries; $i++) {
        try {
            Remove-Item -Path $figmaPath -Recurse -Force -ErrorAction Stop
            Start-Sleep -Seconds $retryDelaySeconds
        } catch {
            Write-Warning "Attempt ${i}: Failed to remove folder: $_"
        }

        if (-not (Test-Path $figmaPath)) {
            return
        }
    }

    Write-Error "Failed to remove Figma installation folder after $maxRetries attempts."
    exit 1
}

# Function to remove Figma Start Menu shortcut with retry
function Remove-FigmaShortcut {
    $shortcutPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Figma.lnk"
    $maxRetries = 3
    $retryDelaySeconds = 2

    if (-not (Test-Path $shortcutPath)) {
        return
    }

    for ($i = 1; $i -le $maxRetries; $i++) {
        try {
            Remove-Item -Path $shortcutPath -Force -ErrorAction Stop
            Start-Sleep -Seconds $retryDelaySeconds
        } catch {
            Write-Warning "Attempt ${i}: Failed to remove shortcut: $_"
        }

        if (-not (Test-Path $shortcutPath)) {
            return
        }
    }

    Write-Error "Failed to remove Figma shortcut after $maxRetries attempts."
    exit 1
}

# Main uninstall logic
Stop-FigmaProcess
Remove-FigmaInstallation
Remove-FigmaShortcut

# Final verification
if (-not (Test-Path "$env:LOCALAPPDATA\Figma") -and -not (Test-Path "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Figma.lnk")) {
    exit 0
} else {
    Write-Error "Figma uninstall failed: folder or shortcut still exists."
    exit 1
}
