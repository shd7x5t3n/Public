# Function to check if Salesforce Data Loader is installed
function Check-SalesforceDataLoader {
    # Define the root directory where we will search for the cached 'install.bat' (or any relevant file)
    $searchRootPath = "C:\"  # You can change this to another root path, such as "D:\" if needed
    $installBatFileName = "install.bat"
    
    # Step 1: Search for the 'install.bat' file recursively within the search root path
    $cachedInstallBatPath = Get-ChildItem -Path $searchRootPath -Recurse -Filter $installBatFileName -ErrorAction SilentlyContinue |
        Select-Object -First 1

    # Step 2: If install.bat is found
    if ($cachedInstallBatPath) {
        Write-Host "'install.bat' found in path: $($cachedInstallBatPath.FullName)"
        
        # Check if Data Loader is installed at the expected directory
        $DataLoaderPath = "C:\Program Files\Salesforce Dataloader\v63.0.0"
        if (Test-Path $DataLoaderPath) {
            Write-Host "Salesforce Data Loader is installed at: $DataLoaderPath"
            exit 0  # Success exit code for Intune (Data Loader is installed)
        } else {
            Write-Host "Salesforce Data Loader is not installed at $DataLoaderPath."
            exit 1  # Error exit code (Data Loader not found)
        }
    } else {
        Write-Host "'install.bat' not found in the search path: $searchRootPath."
        exit 1  # Error exit code (install.bat not found)
    }
}

# Call the function to check for Salesforce Data Loader installation
Check-SalesforceDataLoader
