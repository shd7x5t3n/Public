# Define the specific directory where we will check for 'install.bat'
$DataLoaderPath = Join-Path -Path ${env:ProgramFiles(x86)} -ChildPath "Salesforce Dataloader\v63.0.0"
$installBatFilePath = Join-Path -Path $DataLoaderPath -ChildPath "install.bat"

# Step 1: Check if the Salesforce Data Loader directory exists
if (Test-Path $DataLoaderPath) {
    Write-Host "Salesforce Data Loader directory found at: $DataLoaderPath"

    # Step 2: Check if 'install.bat' exists within the directory
    if (Test-Path $installBatFilePath) {
        Write-Host "'install.bat' found in the Data Loader directory."
        exit 0  # Success exit code for Intune (both directory and install.bat found)
    } else {
        Write-Host "'install.bat' not found in the Data Loader directory at: $installBatFilePath"
        exit 1  # Error exit code (install.bat not found)
    }
} else {
    Write-Host "Salesforce Data Loader directory not found at: $DataLoaderPath"
    exit 1  # Error exit code (Data Loader directory not found)
}
