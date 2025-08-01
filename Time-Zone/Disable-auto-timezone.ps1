# Registry setting to disable automatic time zone updates
$settings = @(
    @{
        Path  = "HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate"
        Name  = "Start"
        Value = 4  # 4 = Disabled
        Type  = "DWord"
    }
)

# Apply registry settings
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

    # Check current value
    $currentValue = (Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue).$Name
    if ($null -eq $currentValue) {
        try {
            $result = New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType $Type -Force -ErrorAction Stop
            Write-Host "Registry value '$Name' set successfully at path '$Path'."
        } catch {
            Write-Host "Failed to set registry value '$Name' at path '$Path'. Error: $_"
            exit 1
        }
    } elseif ($currentValue -ne $Value) {
        try {
            $result = Set-ItemProperty -Path $Path -Name $Name -Value $Value
            Write-Host "Registry value '$Name' updated successfully at path '$Path'."
        } catch {
            Write-Host "Failed to update registry value '$Name' at path '$Path'. Error: $_"
            exit 1
        }
    } else {
        Write-Host "Registry value '$Name' is already set to the correct value at path '$Path'."
    }
}

# Optional: Stop the tzautoupdate service immediately
try {
    Stop-Service -Name "tzautoupdate" -ErrorAction SilentlyContinue
    Write-Host "tzautoupdate service stopped."
} catch {
    Write-Host "Failed to stop tzautoupdate service. It may not be running, which is OK."
}
