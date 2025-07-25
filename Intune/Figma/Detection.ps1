# Minimum required Figma version
$MinimumVersion = [version]'125.6.5'

function Get-FigmaExePath {
    $basePath = "$env:LOCALAPPDATA\Figma"
    if (-not (Test-Path $basePath)) {
        return $null
    }
    $dirs = Get-ChildItem -Path $basePath -Directory -Filter 'app-*' | Sort-Object Name -Descending
    foreach ($dir in $dirs) {
        $exePath = Join-Path $dir.FullName 'figma.exe'
        if (Test-Path $exePath) { 
            return $exePath
        }
    }
    return $null
}

function Get-InstalledVersion($exePath) {
    try {
        return (Get-Item $exePath).VersionInfo.FileVersion
    } catch {
        return $null
    }
}

$FigmaExe = Get-FigmaExePath

if ($FigmaExe) {
    $versionRaw = Get-InstalledVersion $FigmaExe
    if ($versionRaw) {
        $InstalledVersion = [version]$versionRaw
        if ($InstalledVersion -ge $MinimumVersion) {
            Write-Output "Figma installed with version $InstalledVersion which meets minimum requirement $MinimumVersion."
            exit 0   # Installed and version meets or exceeds minimum
        } else {
            Write-Output "Figma installed but version $InstalledVersion is below minimum required $MinimumVersion."
            exit 1   # Installed but version too low
        }
    } else {
        Write-Output "Figma installed but version info could not be retrieved."
        exit 1       # Installed but version info not retrievable
    }
} else {
    Write-Output "Figma is not installed."
    exit 1           # Not installed
}
