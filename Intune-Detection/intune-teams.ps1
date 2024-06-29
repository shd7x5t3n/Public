<# 
.SYNOPSIS 
Install New Microsoft Teams App on target devices and remove classic Teams.
.DESCRIPTION 
Below script will install New MS Teams App Offline and remove classic Teams.

.NOTES     
        Name       : New MS Teams App Installation Offline
        Author     : Jatin Makhija  
        Version    : 1.0.0  
        DateCreated: 12-Jan-2024
        Blog       : https://cloudinfra.net
         
.LINK 
https://cloudinfra.net 
#>
# Define paths and filenames
$msixFile = ".\MSTeams-x64.msix"
$destinationPath = "C:\windows\temp"
$bootstrapperPath = ".\teamsbootstrapper.exe"

# Copy MSTeams-x64.msix to the destination directory
Copy-Item -Path $msixFile -Destination $destinationPath -Force

# Check if the copy operation was successful
if ($?) {
    # If successful, execute teamsbootstrapper.exe to install new Teams
    Start-Process -FilePath $bootstrapperPath -ArgumentList "-p", "-o", "$destinationPath\MSTeams-x64.msix" -Wait -WindowStyle Hidden
    Write-Host "Microsoft Teams installation completed successfully."

    # Remove classic Teams using teamsbootstrapper.exe with -u parameter
    Start-Process -FilePath $bootstrapperPath -ArgumentList "-u" -Wait -WindowStyle Hidden
    Write-Host "Classic Microsoft Teams removal completed successfully."
} else {
    # If copy operation failed, display an error message
    Write-Host "Error: Failed to copy MSTeams-x64.msix to $destinationPath."
    exit 1
}
