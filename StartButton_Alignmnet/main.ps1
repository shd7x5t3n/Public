# Check for Windows 11

# Define the minimum required Windows version
$minimumVersion = [version]"10.0.22000"

# Check if the current Windows version is greater than or equal to the minimum version
if ($([System.Environment]::OSVersion.Version) -ge $minimumVersion) {
    # Your Windows version is supported. Continuing with the script.
} else {
    # Windows 11 is not installed, or the version is not compatible. Exiting script.
    exit 1
}

# Script continues here if Windows 11 is installed
# Windows 11 is installed or a compatible version is present.

# Define variables
$registryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
$propertyName = "TaskbarAl"
$newValue = 0
$valueType = "DWORD"

# Get the current registry value
$currentValue = Get-ItemPropertyValue -Path $registryPath -Name $propertyName -ErrorAction SilentlyContinue

# Check if the current value is not equal to 0
if (!($currentValue -eq $newValue)) {
    # Set registry property
    Set-ItemProperty -Path $registryPath -Name $propertyName -Value $newValue -Type $valueType -Force
    # Taskbar position set to the left.
} else {
    # Taskbar is already set to the left. No changes needed.
}
