# Define Tenant and App Credentials
$tenantId = " "
$clientId = " "
$clientSecret = ConvertTo-SecureString " " -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential($clientId, $clientSecret)

# Connect to Microsoft Graph
Connect-MgGraph -NoWelcome -ClientSecretCredential $credential -TenantId $tenantId

# Define the target group name
$groupName = "MFA-Users"

# Retrieve the group object ID dynamically
try {
    $group = Get-MgGroup -Filter "DisplayName eq '$groupName'" -Select Id -ConsistencyLevel eventual
    if (-not $group) {
        Write-Host "Error: Group '$groupName' not found." -ForegroundColor Red
        exit
    }
    $groupId = $group.Id
} catch {
    Write-Host "Error retrieving group: $_" -ForegroundColor Red
    exit
}

# Retrieve all current group members to minimize redundant API calls
try {
    $groupMembers = Get-MgGroupMember -GroupId $groupId -All | Select-Object -ExpandProperty Id
} catch {
    Write-Host "Error retrieving group members: $_" -ForegroundColor Red
    exit
}

# Retrieve all users
try {
    $users = Get-MgUser -All
    if (-not $users) {
        Write-Host "No users found." -ForegroundColor Yellow
        exit
    }
} catch {
    Write-Host "Error retrieving users: $_" -ForegroundColor Red
    exit
}

# Initialize results array
$results = @()

foreach ($user in $users) {
    try {
        # Retrieve authentication methods for each user
        $authMethods = Get-MgUserAuthenticationMethod -UserId $user.Id | Select-Object -ExpandProperty AdditionalProperties
        
        # Check if user has at least one MFA method
        $mfaMethods = @(
            "#microsoft.graph.microsoftAuthenticatorAuthenticationMethod",
            "#microsoft.graph.softwareOathAuthenticationMethod",
            "#microsoft.graph.fido2AuthenticationMethod",
            "#microsoft.graph.passwordlessMicrosoftAuthenticatorAuthenticationMethod"
        )

        $hasMFA = $mfaMethods | Where-Object { $authMethods.Values -match $_ }

        # Proceed only if the user has at least one MFA method
        if ($hasMFA) {
            $isMember = $groupMembers -contains $user.Id
            $status = "Already a Member"

            # If user is not in the group, add them
            if (-not $isMember) {
                try {
                    New-MgGroupMember -GroupId $groupId -DirectoryObjectId $user.Id
                    $status = "Added to Group"
                } catch {
                    $status = "Failed to Add: $_"
                }
            }

            # Store results
            $results += [PSCustomObject]@{
                User                   = $user.DisplayName
                UserId                 = $user.Id
                MicrosoftAuthenticator = If ($authMethods.Values -match $mfaMethods[0]) {"Yes"} Else {"No"}
                SoftwareOath           = If ($authMethods.Values -match $mfaMethods[1]) {"Yes"} Else {"No"}
                Fido2                  = If ($authMethods.Values -match $mfaMethods[2]) {"Yes"} Else {"No"}
                Passwordless           = If ($authMethods.Values -match $mfaMethods[3]) {"Yes"} Else {"No"}
                GroupMembership        = $status
            }
        }
    } catch {
        Write-Host "Error processing user $($user.DisplayName): $_" -ForegroundColor Red
    }
}

# Display results in table format
$results | Format-Table -AutoSize
