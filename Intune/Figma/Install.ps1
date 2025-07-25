# Minimum required Figma version
$MinimumVersion = [version]'125.6.5'

# Figma installer URL and temp path
$InstallerUrl = 'https://www.figma.com/download/desktop/win'
$InstallerPath = "$env:TEMP\FigmaSetup.exe"
$FigmaBasePath = "$env:LOCALAPPDATA\Figma"

function Get-FigmaExePath {
    if (-not (Test-Path $FigmaBasePath)) { return $null }
    $appDirs = Get-ChildItem -Path $FigmaBasePath -Directory -Filter 'app-*' | Sort-Object Name -Descending
    foreach ($dir in $appDirs) {
        $exePath = Join-Path $dir.FullName 'figma.exe'
        if (Test-Path $exePath) { return $exePath }
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

function Download-FigmaInstaller {
    $retryCount = 3
    $attempt = 0
    $success = $false

    while ($attempt -lt $retryCount -and -not $success) {
        try {
            Invoke-WebRequest -Uri $InstallerUrl -OutFile $InstallerPath -UseBasicParsing -ErrorAction Stop
            $success = $true
        } catch {
            $attempt++
            Start-Sleep -Seconds 5
        }
    }

    if (-not $success) {
        exit 1
    }
}

function Install-Figma {
    try {
        $process = Start-Process -FilePath $InstallerPath -Wait -PassThru
        if ($process.ExitCode -ne 0) { exit 1 }

        # Monitor for figma process and kill immediately
        $maxWaitSeconds = 30
        $elapsed = 0
        do {
            Start-Sleep -Seconds 1
            $elapsed++
            $figmaProcess = Get-Process -Name "figma" -ErrorAction SilentlyContinue
        } while (-not $figmaProcess -and $elapsed -lt $maxWaitSeconds)

        if ($figmaProcess) {
            $figmaProcess | Stop-Process -Force -ErrorAction SilentlyContinue
        }
    } finally {
        if (Test-Path $InstallerPath) {
            Remove-Item -Path $InstallerPath -Force -ErrorAction SilentlyContinue
        }
    }
}

$FigmaExePath = Get-FigmaExePath
$needsInstall = $true

if ($FigmaExePath) {
    $InstalledVersionRaw = Get-InstalledVersion $FigmaExePath
    if ($InstalledVersionRaw) {
        $InstalledVersion = [version]$InstalledVersionRaw
        if ($InstalledVersion -ge $MinimumVersion) {
            $needsInstall = $false
        }
    }
}

if ($needsInstall) {
    Download-FigmaInstaller
    Install-Figma
    exit 0
} else {
    exit 0
}
