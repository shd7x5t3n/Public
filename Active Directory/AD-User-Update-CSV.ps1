# Import the Active Directory module
Import-Module ActiveDirectory

# Path to the CSV file
$csvPath = "C:\OP\User1.csv"

# Import the CSV file
$users = Import-Csv -Path $csvPath

# Iterate through each user in the CSV
foreach ($user in $users) {
    $userPrincipalName = $user.userPrincipalName
    $csvOfficeName = $user.physicalDeliveryOfficeName

    try {
        # Get the current user's AD object
        $adUser = Get-ADUser -Filter {UserPrincipalName -eq $userPrincipalName} -Property physicalDeliveryOfficeName

        if ($adUser) {
            # Get the current office name
            $currentOfficeName = $adUser.physicalDeliveryOfficeName

            # Compare and update if necessary
            if ($currentOfficeName -ne $csvOfficeName) {
                Write-Host "Updating ${userPrincipalName}: ${currentOfficeName} -> ${csvOfficeName}"
                
                # Update the physicalDeliveryOfficeName attribute
                Set-ADUser -Identity $adUser.DistinguishedName -Replace @{physicalDeliveryOfficeName = $csvOfficeName}
            } else {
                Write-Host "${userPrincipalName} is already up-to-date."
            }
        } else {
            Write-Warning "User ${userPrincipalName} not found in Active Directory."
        }
    } catch {
        Write-Warning "Failed to process ${userPrincipalName}: $_"
    }
}
