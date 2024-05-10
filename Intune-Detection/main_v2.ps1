# Define the registry path where uninstall information is stored
$registryPath = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'

# Query the registry for information about any installed software with 'Global' in its name
$globalProtect = Get-ItemProperty -Path $registryPath | Where-Object { $_.DisplayName -like '*global*' }

# Check if Global Protect is found
if ($globalProtect) {
    # Output the detected version of Global Protect
    $version = $globalProtect.DisplayVersion
    Write-Output "Global Protect detected. Version: $version"
    
    # Output the ModifyPath to verify the presence of the product code
    Write-Output "ModifyPath: $($globalProtect.ModifyPath)"
    
    # Extract the MSI product code from the ModifyPath property
    $productCode = $globalProtect.ModifyPath -replace '^.*?(\{[A-F0-9\-]+\}).*$', '$1'
    Write-Output "Extracted Product Code: $productCode"
    
    # Define the uninstallation command using the extracted product code
    $uninstallCommand = "msiexec /x `"$productCode`" /qn"
    Write-Output "Uninstall Command: $uninstallCommand"
    
    # Execute the uninstallation command and capture outputs
    $uninstallResult = Start-Process -FilePath 'msiexec.exe' -ArgumentList "/x `"$productCode`" /qn" -Wait -PassThru -NoNewWindow
    
    # Check if the uninstallation was successful
    if ($uninstallResult.ExitCode -eq 0) {
        Write-Output "Global Protect version $version has been uninstalled."
    } else {
        Write-Output "Failed to uninstall Global Protect. Exit code: $exitCode"
    }
} else {
    # If Global Protect is not found
    Write-Output "Global Protect is not installed."
}
