# Registry settings
$settings = @(
    @{
        Path  = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location"
        Name  = "Value"
        Value = "Allow"
        Type  = "String"
    },
    @{
        Path  = "HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate"
        Name  = "Start"
        Value = 3
        Type  = "DWord"
    }
)

# Iterate through each registry setting
$settings | ForEach-Object {
    $Path = $_.Path
    $Name = $_.Name
    $Value = $_.Value
    $Type = $_.Type

    # Create the registry key if it doesn't exist
    if (-not (Test-Path $Path -PathType Container)) {
        try {
            $null = New-Item -Path $Path -ItemType Directory -Force -ErrorAction Stop
            Write-Host "Registry key '$Path' created."
        } catch {
            Write-Host "Failed to create registry key '$Path'. Error: $_"
            exit 1
        }
    }

    # Check if registry value exists and is correct
    $currentValue = (Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue).$Name
    if ($null -eq $currentValue) {
        try {
            $result = New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType $Type -Force -ErrorAction Stop
            Write-Host "Registry key '$Name' set successfully at path '$Path'."
        } catch {
            Write-Host "Failed to set registry key '$Name' at path '$Path'. Error: $_"
            exit 1
        }
    } elseif ($currentValue -ne $Value) {
        try {
            $result = Set-ItemProperty -Path $Path -Name $Name -Value $Value
            Write-Host "Registry key '$Name' updated successfully at path '$Path'."
        } catch {
            Write-Host "Failed to update registry key '$Name' at path '$Path'. Error: $_"
            exit 1
        }
    } else {
        Write-Host "Registry key '$Name' is already set to the correct value at path '$Path'."
    }
}

# Additional actions:
# Start Location Services
try {
    Start-Service -Name "lfsvc" -ErrorAction Stop
    Write-Host "Location Services started successfully."
} catch {
    Write-Host "Failed to start Location Services. Error: $_"
    exit 1
}

# Resynchronize Time
try {
    w32tm /resync
    Write-Host "Time resynchronized successfully."
} catch {
    Write-Host "Failed to resynchronize time. Error: $_"
    exit 1
}
