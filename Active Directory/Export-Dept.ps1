# List of departments to filter on
$departments = @("Information Technology", "Security", "Dev")

# Prepare manager cache
$managerCache = @{}

# Get enabled users with required properties
$users = Get-ADUser -Filter 'Enabled -eq $true' -Properties GivenName, SN, Title, Department, Manager

# Filter by department
$filteredUsers = $users | Where-Object {
    $_.Department -and ($departments -contains $_.Department)
}

# Format user export data
$export = $filteredUsers | Select-Object `
    @{Name='GivenName';Expression={$_.GivenName}},
    @{Name='Surname';Expression={$_.SN}},
    @{Name='Title';Expression={$_.Title}},
    @{Name='Department';Expression={$_.Department}},
    @{Name='SamAccountName';Expression={$_.SamAccountName}},
    @{Name='Manager';Expression={
        if ($_.Manager) {
            if (-not $managerCache.ContainsKey($_.Manager)) {
                $managerUser = Get-ADUser -Identity $_.Manager -Properties SamAccountName
                $managerCache[$_.Manager] = $managerUser.SamAccountName
            }
            $managerCache[$_.Manager]
        } else {
            ""
        }
    }}

# Add a row for the total count
$totalRow = [PSCustomObject]@{
    GivenName      = ""
    Surname        = ""
    Title          = ""
    Department     = ""
    SamAccountName = "Total Users:"
    Manager        = $export.Count
}

# Combine the user data and total row
$finalExport = $export + $totalRow

# Export to CSV
$finalExport | Export-Csv -Path "C:\org.csv" -NoTypeInformation

Write-Output "Export complete. File saved to C:\org.csv"
