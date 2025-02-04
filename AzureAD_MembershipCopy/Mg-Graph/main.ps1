# Include necessary scripts
. ".\processing.ps1"
. ".\logging.ps1"
. ".\validation.ps1"

# Function that checks if a PowerShell module is already installed and installs it if not.
# It also imports the module and handles administrator rights, providing a convenient way to ensure the required module is available for use in the script.
function Install-AndImportModule {
    param(
        [string]$moduleName,
        [string]$moduleCheckCommand
    )

    if (-not (Get-Module -Name $moduleName -ListAvailable)) {
        $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

        if (-not $isAdmin) {
            Write-Log "This script requires administrator rights to install the $moduleName module. Please run the script as an administrator." "ERROR"
            exit
        }

        Write-Log "Installing $moduleName module..." "INFO"
        Install-Module -Name $moduleName -Force
    }
    Import-Module $moduleName -ErrorAction Stop
}

function Main {
    Write-Log "Starting script execution." "INFO"

    # Prompt for valid user email input
    $upn1, $upn2 = Get-UniqueEmailInputs

    # Install and import required modules
    Install-AndImportModule -moduleName "AzureAD" -moduleCheckCommand "Get-Module -Name AzureAD -ListAvailable"
    Install-AndImportModule -moduleName "ExchangeOnlineManagement" -moduleCheckCommand "Get-Module -Name ExchangeOnlineManagement -ListAvailable"

    # Assuming Connect-AzureAD is a function defined in one of the sourced scripts
    Connect-AzureAD

    # Get both users' ObjectIds
    $user1 = Get-AzureADUser -Filter "UserPrincipalName eq '$upn1'"
    $user2 = Get-AzureADUser -Filter "UserPrincipalName eq '$upn2'"

    if ($user1 -eq $null) {
        Write-Log "User '$upn1' not found." "ERROR"
    } elseif ($user2 -eq $null) {
        Write-Log "User '$upn2' not found." "ERROR"
    } else {
        $user1ObjectId = $user1.ObjectId
        $user2ObjectId = $user2.ObjectId

        $user1Groups = Get-MgUserMemberOf -userid $user1ObjectId -all | where-object {$_.AdditionalProperties.securityEnabled -eq 'True' -and $_.AdditionalProperties.mailEnabled -eq 'True' -and $_.AdditionalProperties.dirSyncEnabled -ne 'True'}
        $user2Groups = Get-MgUserMemberOf -userid $user2ObjectId -all | where-object {$_.AdditionalProperties.securityEnabled -eq 'True' -and $_.AdditionalProperties.mailEnabled -eq 'True' -and $_.AdditionalProperties.dirSyncEnabled -ne 'True'}

        Process-AD -upn1 $upn1 -upn2 $upn2 -validatelocalad 1
        Write-Log ""
        Process-GroupMembership -upn1 $upn1 -upn2 $upn2 -user1ObjectId $user1ObjectId -user2ObjectId $user2ObjectId -user1Groups $user1Groups -user2Groups $user2Groups
        Write-Log ""
        Process-DistributionGroupMembership -upn1 $upn1 -upn2 $upn2
        Write-Log ""
        Process-MailEnableSecurityGroup -upn1 $upn1 -upn2 $upn2 
        Write-Log ""
        Process-M365GroupMembership -upn1 $upn1 -upn2 $upn2 
    }

    Write-Log "Script execution completed." "INFO"
}

# Execute the main script
Main | Out-Null
