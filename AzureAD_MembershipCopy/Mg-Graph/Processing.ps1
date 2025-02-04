# Function that attempts to add a user to an Azure AD group using their object IDs and provides logging for success or failure, 
#making it a useful utility for managing Azure AD group memberships.
function Add-UserToGroup {
    param(
        [string]$userObjectId,
        [string]$groupObjectId,
        [string]$userUpn,
        [string]$groupName
    )

    try {
        Add-AzureADGroupMember -ObjectId $groupObjectId -RefObjectId $userObjectId -ErrorAction Stop
        Write-Log "Added $userUpn to Azure AD group $groupName" "INFO"
    } catch {
        Write-Log "Failed to add $userUpn to Azure AD group $groupName" "ERROR"
    }
}


#This PowerShell function, named Process-AD, is designed to facilitate the management of Active Directory (AD) group memberships. 
#It takes two user principal names (UPNs) as input and an optional validation flag. When the validation flag is set to 1,
#it extracts the usernames from the UPNs, retrieves the source user's AD groups, and checks if the destination user is already a member of those groups.
#If not, it adds the destination user to the specified AD groups and logs the actions taken.
function Process-AD {
    param (
        [string]$upn1,
        [string]$upn2,
        [int]$validatelocalad = 0
    )

    if ($validatelocalad -eq 1) {
        # Extract the usernames without domain from UPN
        $username1 = $upn1.Split('@')[0]
        $username2 = $upn2.Split('@')[0]

        # Get the source user's groups
        $sourceUserGroups = Get-ADPrincipalGroupMembership -Identity $username1

        foreach ($group in $sourceUserGroups) {
            $groupDetails = Get-ADGroup -Identity $group
            $groupId = $groupDetails.ObjectGuid

            # Check if the group name contains "dnaFusion"
            if ($groupDetails.Name -like "*dnaFusion*") {
                 Write-Log "Skipping $upn2 for group $($groupDetails.Name) as it contains 'dnaFusion'" "INFO"
                 continue
     }

            # Check if the destination user is already a member of the group
            $groupMembers = Get-ADGroupMember -Identity $group
            $isMember = $groupMembers | Where-Object { $_.SamAccountName -eq $username2 }

            if ($isMember -eq $null) {
                # Add the destination user to the group
                Add-ADGroupMember -Identity $group -Members $username2
                Write-Log "Added $upn2 to local AD group $($groupDetails.Name)" "INFO"
            } else {
                Write-Log "$upn2 is already a member of local AD group $($groupDetails.Name)" "INFO"
            }
        }

        Write-Log "Completed adding $username2 to groups of $upn1" "INFO"
    }
}


# Function to process group membership for two users in Azure AD. It iterates through user1's groups, 
#checks if user2 is already a member of those groups, and adds them if not, providing informative logging along the way.
# This function simplifies the management of group memberships between users.
function Process-GroupMembership {
    param(
        [string]$upn1,
        [string]$upn2,
        [string]$user1ObjectId,
        [string]$user2ObjectId,
        [array]$user1Groups,
        [array]$user2Groups
    )

    foreach ($group1 in $user1Groups) {
        $group1Details = Get-AzureADGroup -ObjectId $group1.ObjectId
        $groupId = $group1Details.ObjectId

        if ($user2Groups.ObjectId -contains $groupId) {
            Write-Log "$upn2 is already a member of Azure AD group $($group1Details.DisplayName)" "INFO"
        } else {
            Add-UserToGroup -userObjectId $user2ObjectId -groupObjectId $groupId -userUpn $upn2 -groupName $group1Details.DisplayName
        }
    }

    Write-Log "$upn2 has been added to Azure AD groups that $upn1 is a member of." "INFO"
}

# Function to process distribution group membership connects to Exchange Online and manages membership in distribution groups. 
#It checks if user2 is already a member of distribution groups user1 belongs to and adds them if not, while providing informative 
#logging throughout the process. This function simplifies the management of distribution group memberships in an Exchange Online environment.
function Process-DistributionGroupMembership {
    param(
        [string]$upn1,
        [string]$upn2
    )

    Connect-ToExchangeOnline

    $groups = Get-DistributionGroup -ResultSize Unlimited | Where-Object { Get-DistributionGroupMember $_ | Where-Object { $_.PrimarySmtpAddress -eq $upn1 } }

    foreach ($group in $groups) {
        $groupDisplayName = $group.DisplayName
        $isMember = Get-DistributionGroupMember -Identity $groupDisplayName | Where-Object { $_.PrimarySmtpAddress -eq $upn2 }

        if ($isMember) {
            Write-Log "User $upn2 is already a member of Distribution Group $groupDisplayName" "INFO"
        } else {
            Add-DistributionGroupMember -Identity $groupDisplayName -Member $upn2 -BypassSecurityGroupManagerCheck
            Write-Log "Added $upn2 to Distribution Group $groupDisplayName" "INFO"
        }
    }

   
}

#This function manages membership in mail-enabled security groups. It checks if user2 is already a member of mail-enabled security groups 
#that user1 belongs to and adds them if not, providing informative logging for the process. 
#This function simplifies the management of mail-enabled security group memberships.
function Process-MailEnableSecurityGroup {
    param(
        [string]$upn1,
        [string]$upn2
    )

   

    $mailenablegroups = Get-DistributionGroup -ResultSize Unlimited | Where-Object { $_.RecipientTypeDetails -eq "MailUniversalSecurityGroup" -and (Get-DistributionGroupMember $_ | Where-Object { $_.PrimarySmtpAddress -eq $upn1 }) }

    foreach ($group in $mailenablegroups) {
        $groupDisplayName = $group.DisplayName
        $isMember = Get-DistributionGroupMember -Identity $groupDisplayName | Where-Object { $_.PrimarySmtpAddress -eq $upn2 }

        if ($isMember) {
            Write-Log "User $upn2 is already a member of Mail Enabled Security Group $groupDisplayName" "INFO"
        } else {
            Add-DistributionGroupMember -Identity $groupDisplayName -Member $upn2 -BypassSecurityGroupManagerCheck
            Write-Log "Added $upn2 to Mail Enabled Security Group $groupDisplayName" "INFO"
        }
    }

   
}

#This function  manages membership in Microsoft 365 (M365) groups. It checks if user2 is already a member of M365 groups that user1 belongs to and adds them if not, 
#providing informative logging for the process. This function simplifies the management of M365 group memberships in an Exchange Online environment.
function Process-M365GroupMembership {
    param(
        [string]$upn1,
        [string]$upn2
    )

    $unifiedGroups = Get-UnifiedGroup -ResultSize Unlimited | Where-Object { Get-UnifiedGroupLinks -Identity $_.Id -LinkType Members | Where-Object { $_.PrimarySmtpAddress -eq $upn1 } }

    foreach ($group in $unifiedGroups) {
        $groupId = $group.Id
        $groupDisplayName = $group.DisplayName
        $isMember = Get-UnifiedGroupLinks -Identity $groupId -LinkType Members | Where-Object { $_.PrimarySmtpAddress -eq $upn2 }

        if ($isMember) {
            Write-Log "User $upn2 is already a member of Microsoft 365 Group $groupDisplayName" "INFO"
        } else {
            Add-UnifiedGroupLinks -Identity $groupId -LinkType Members -Links $upn2 -ErrorAction SilentlyContinue
            Write-Log "Added $upn2 to Microsoft 365 Group $groupDisplayName" "INFO"
        }
    }

    Disconnect-ExchangeOnline -Confirm:$false
}
