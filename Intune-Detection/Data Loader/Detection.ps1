# Function to check if Salesforce Data Loader is installed
function Check-SalesforceDataLoader {
    $DataLoaderPath = "C:\Program Files\Salesforce Dataloader\v63.0.0"
    $InstallBatPath = Join-Path -Path $DataLoaderPath -ChildPath "install.bat"
    
    # Check if the Data Loader directory exists
    if (Test-Path $DataLoaderPath) {
        Write-Host "Salesforce Data Loader is installed at: $DataLoaderPath"
        
        # Check if install.bat exists within the directory
        if (Test-Path $InstallBatPath) {
            Write-Host "'install.bat' found, indicating a valid installation."
            exit 0  # Success exit code for Intune
        } else {
            Write-Host "'install.bat' not found in the expected location."
            exit 1  # Error exit code for missing install.bat
        }
    } else {
        Write-Host "Salesforce Data Loader is not installed at $DataLoaderPath."
        exit 1  # Error exit code for missing Data Loader directory
    }
}

# Call the function to check for installation
Check-SalesforceDataLoader
