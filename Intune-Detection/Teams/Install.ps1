# Parameters and defaults
[string]$NewTeamsInstaller      = ".\teamsbootstrapper.exe"  # Path to the new Teams installer
[string]$NewTeamsInstallerArgs  = "-p"                         # Arguments for the new Teams installer
[bool]$RemovePersonalTeams      = $true                        # Remove Personal Teams to avoid confusion

# Function to uninstall an application by its name
function Uninstall-App {
    param (
        [string]$AppName
    )
    $uninstallKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
    $app = Get-ChildItem -Path $uninstallKey | Get-ItemProperty | Where-Object { $_.DisplayName -like "*$AppName*" }
    
    if ($app) {
        Start-Process "MsiExec.exe" -ArgumentList "/X $($app.PSChildName) /qn /norestart" -Wait
    }
}

# Function to remove registry keys
function Remove-RegistryKeys {
    param (
        [string]$registryPath,
        [string[]]$keyNames
    )
    foreach ($keyName in $keyNames) {
        if (Test-Path -Path "$registryPath\$keyName") {
            Remove-Item -Path "$registryPath\$keyName" -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

# Stop all Classic Teams processes
Get-Process "teams*" -ErrorAction SilentlyContinue | Stop-Process -Force

# Remove Personal Teams if specified
if ($RemovePersonalTeams) {
    Get-AppxPackage "MicrosoftTeams*" -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
}

# Uninstall Classic Teams appx packages
Get-AppxPackage "Teams*" -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue

# Uninstall Classic Teams Machine-Wide Installer
Uninstall-App -AppName "Teams Machine-Wide Installer"

# Paths for Classic Teams installation
$paths = @(
    "${env:ProgramFiles(x86)}\Teams Installer\update.exe",
    "${env:ProgramFiles}\Teams Installer\update.exe",
    "${env:ProgramFiles(x86)}\Microsoft\Teams\current\update.exe",
    "${env:ProgramFiles}\Microsoft\Teams\current\update.exe"
)

# Uninstall from the specified paths
foreach ($path in $paths) {
    if (Test-Path $path) {
        Start-Process -FilePath $path -ArgumentList "--uninstall -s" -Wait
    }
}

# Uninstall Classic Teams from user profiles
$userDirectories = Get-ChildItem -Path (Split-Path $env:USERPROFILE) -Directory
foreach ($userDirectory in $userDirectories) {
    $userPath = Join-Path $userDirectory "AppData\Local\Microsoft\Teams\update.exe"
    if (Test-Path $userPath) {
        Start-Process -FilePath $userPath -ArgumentList "--uninstall -s" -Wait
    }
}

# Cleanup Classic Teams folders
$foldersToRemove = @(
    "$env:ProgramData\Microsoft\Teams",
    "$env:USERPROFILE\AppData\Local\Microsoft\Teams",
    "$env:USERPROFILE\AppData\Roaming\Microsoft\Teams"
)

foreach ($folder in $foldersToRemove) {
    Remove-Item -Path $folder -Recurse -Force -ErrorAction SilentlyContinue
}

# Define registry paths and key names for Teams
$registryPaths = @(
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run',
    'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run',
    'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run',
    'HKCU:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run'
)

$keyNames = @(
    'Teams',
    'TeamsMachineUninstallerLocalAppData',
    'TeamsMachineUninstallerProgramData',
    'com.squirrel.Teams.Teams',
    'TeamsMachineInstaller'
)

# Remove Classic Teams from startup registry keys
foreach ($registryPath in $registryPaths) {
    Remove-RegistryKeys -registryPath $registryPath -keyNames $keyNames
}

# Install New Teams
$process = Start-Process -FilePath $NewTeamsInstaller -ArgumentList $NewTeamsInstallerArgs -PassThru -Wait -ErrorAction Stop
if ($process.ExitCode -ne 0) {
    exit 1  # Installation failed
}

exit 0  # Script completed successfully
