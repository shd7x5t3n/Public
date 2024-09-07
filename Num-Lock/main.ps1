# Registry settings
$settings = @(
    @{
        Path  = "HKCU:\Control Panel\Keyboard"
        Name  = "InitialKeyboardIndicators"
        Value = "2"
        Type  = "DWord"
    },
    @{
        Path  = "Registry::HKEY_USERS\.DEFAULT\Control Panel\Keyboard"
        Name  = "InitialKeyboardIndicators"
        Value = "2147483650"
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
            New-Item -Path $Path -ItemType Directory -Force -ErrorAction Stop | Out-Null
            Write-Host "Registry key '$Path' created."
        } catch {
            Write-Host "Failed to create registry key '$Path'. Error: $_"
            exit 1
        }
    }

    # Check if registry value exists and is correct
    try {
        $currentValue = Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue
        if ($null -eq $currentValue) {
            # Value does not exist, create it
            New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType $Type -Force -ErrorAction Stop
            Write-Host "Registry key '$Name' set successfully at path '$Path'."
        } elseif ($currentValue.$Name -ne $Value) {
            # Value exists but is different, update it
            Set-ItemProperty -Path $Path -Name $Name -Value $Value -ErrorAction Stop
            Write-Host "Registry key '$Name' updated successfully at path '$Path'."
        } else {
            Write-Host "Registry key '$Name' is already set to the correct value at path '$Path'."
        }
    } catch {
        Write-Host "Failed to set registry key '$Name' at path '$Path'. Error: $_"
        exit 1
    }
}
