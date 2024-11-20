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

            # If the CSV value is not already part of the current office name
            if ($currentOfficeName -notlike "*$csvOfficeName*") {
                $newOfficeName = "Franklin - $csvOfficeName"

                # Update the physicalDeliveryOfficeName attribute
                Write-Host "Updating ${userPrincipalName}: '${currentOfficeName}' -> '${newOfficeName}'"
                Set-ADUser -Identity $adUser.DistinguishedName -Replace @{physicalDeliveryOfficeName = $newOfficeName}
            } else {
                Write-Host "${userPrincipalName} is already up-to-date with '${currentOfficeName}'."
            }
        } else {
            Write-Warning "User ${userPrincipalName} not found in Active Directory."
        }
    } catch {
        Write-Warning "Failed to process ${userPrincipalName}: $_"
    }
}
