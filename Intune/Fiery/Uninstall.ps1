# Define registry paths to search
$registryPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
)

$uninstallString = $null

# Search uninstall registry keys
foreach ($path in $registryPaths) {
    $subkeys = Get-ChildItem -Path $path -ErrorAction SilentlyContinue

    foreach ($subkey in $subkeys) {
        $props = Get-ItemProperty -Path $subkey.PSPath -ErrorAction SilentlyContinue
        $displayName = $props.DisplayName

        if ($displayName -like "*Fiery Command WorkStation*") {
            $uninstallString = $props.UninstallString
            Write-Host "Found uninstall entry for: $displayName"
            break
        }
    }

    if ($uninstallString) { break }
}

# Exit if not found
if (-not $uninstallString) {
    Write-Host "Fiery Command WorkStation not found in uninstall registry keys."
    exit 1
}

# Show the raw uninstall string
Write-Host "Raw UninstallString from registry: $uninstallString"

# Parse the uninstall string safely
if ($uninstallString -match '^"([^"]+)"\s*(.*)$') {
    $exe = $matches[1]
    $args = $matches[2]
} elseif ($uninstallString -match '^([^\s]+)\s*(.*)$') {
    $exe = $matches[1]
    $args = $matches[2]
} else {
    Write-Host "Unable to parse uninstall string: $uninstallString"
    exit 1
}

# Show parsed executable and arguments
Write-Host "Parsed executable: $exe"
Write-Host "Original arguments: $args"

# Append proper silent uninstall switches
$additionalArgs = "/clone_wait /hide_progress SILENT"
$args = "$args $additionalArgs".Trim()

Write-Host "Final arguments: $args"

# Validate the executable path
if (-not (Test-Path $exe)) {
    Write-Host "Uninstaller not found at expected location: $exe"
    exit 1
}

# Run the uninstaller
try {
    $process = Start-Process -FilePath $exe -ArgumentList $args -Wait -PassThru
    Write-Host "Uninstall process completed with exit code: $($process.ExitCode)"

    if ($process.ExitCode -eq 0) {
        Write-Host "Uninstall successful."
        exit 0
    } else {
        Write-Host "Uninstall failed with exit code: $($process.ExitCode)"
        exit 1
    }
}
catch {
    Write-Host "Failed to start uninstall process: $_"
    exit 1
}
