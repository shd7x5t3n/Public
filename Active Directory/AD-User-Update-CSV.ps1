# Import the Active Directory module
Import-Module ActiveDirectory

# Path to the CSV file
$csvPath = "C:\OP\User1.csv"

# Import the CSV file
$users = Import-Csv -Path $csvPath

# Function to validate and standardize the office name
function Get-StandardizedOfficeName {
    param (
        [string]$officeName
    )
    # Check if the office name already matches the required format
    if ($officeName -match '^Franklin - \d+$') {
        return $officeName
    }

    # Extract the number and construct the standardized name
    if ($officeName -match '\d+') {
        $number = $matches[0]
        return "Franklin - $number"
    }

    # If no valid number is found, return a default or handle as required
    return "Franklin - Unknown"
}

# Iterate through each user in the CSV
foreach ($user in $users) {
    $userPrincipalName = $user.userPrincipalName

    try {
        # Get the current user's AD object
        $adUser = Get-ADUser -Filter {UserPrincipalName -eq $userPrincipalName} -Property physicalDeliveryOfficeName

        if ($adUser) {
            # Get the current office name
            $currentOfficeName = $adUser.physicalDeliveryOfficeName

            # Standardize the current office name
            $standardizedOfficeName = Get-StandardizedOfficeName -officeName $currentOfficeName

            # Update if the standardized name is different from the current name
            if ($currentOfficeName -ne $standardizedOfficeName) {
                Write-Host "Updating ${userPrincipalName}: '${currentOfficeName}' -> '${standardizedOfficeName}'"
                Set-ADUser -Identity $adUser.DistinguishedName -Replace @{physicalDeliveryOfficeName = $standardizedOfficeName}
            } else {
                Write-Host "${userPrincipalName} is already in the correct format."
            }
        } else {
            Write-Warning "User ${userPrincipalName} not found in Active Directory."
        }
    } catch {
        Write-Warning "Failed to process ${userPrincipalName}: $_"
    }
}
