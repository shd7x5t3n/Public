# Connect to Microsoft Graph
Connect-MgGraph -Scopes "User.Read.All", "Directory.Read.All"

# Define departments for exact match
$departments = @("Information Technology", "Marketing", "Sales")

# Manager lookup cache
$managerCache = @{}

# Get all enabled users with selected properties
$users = Get-MgUser -Filter "accountEnabled eq true" `
    -Select "Id,DisplayName,GivenName,Surname,JobTitle,Department,UserPrincipalName,UserType" -All

# Filter: only human users
$realUsers = $users | Where-Object {
    $_.UserType -eq "Member" -and
    $_.UserPrincipalName -notmatch "^svc-|^room|^shared" -and
    $_.DisplayName -notmatch "Resource|Room|Test|Service" -and
    ($_.JobTitle -or $_.Department)
}

# Filter by department (exact match)
$filteredUsers = $realUsers | Where-Object {
    $_.Department -and ($departments -contains $_.Department)
}

# Build export with manager lookup
$export = foreach ($user in $filteredUsers) {
    $managerUPN = ""
    if ($user.Id -and -not $managerCache.ContainsKey($user.Id)) {
        try {
            $managerObj = Get-MgUserManager -UserId $user.Id -ErrorAction Stop
            if ($managerObj -and $managerObj.AdditionalProperties.userPrincipalName) {
                $managerUPN = $managerObj.AdditionalProperties.userPrincipalName
            }
        } catch {
            if ($_.Exception.Message -like "*Resource 'manager' does not exist*") {
                $managerUPN = ""
            } else {
                Write-Warning "Error getting manager for $($user.UserPrincipalName): $_"
            }
        }
        $managerCache[$user.Id] = $managerUPN
    } else {
        $managerUPN = $managerCache[$user.Id]
    }

    [PSCustomObject]@{
        GivenName      = $user.GivenName
        Surname        = $user.Surname
        Title          = $user.JobTitle
        Department     = $user.Department
        SamAccountName = $user.UserPrincipalName
        Manager        = $managerUPN
    }
}

# Sort alphabetically
$sortedExport = $export | Sort-Object Surname, GivenName

# Add total row
$totalRow = [PSCustomObject]@{
    GivenName      = ""
    Surname        = ""
    Title          = ""
    Department     = ""
    SamAccountName = "Total Users:"
    Manager        = $export.Count
}

# Combine and export to CSV
$finalExport = $sortedExport + $totalRow
$exportPath = "C:\org.csv"
$finalExport | Export-Csv -Path $exportPath -NoTypeInformation -Encoding UTF8

Write-Output "Export complete. File saved to $exportPath"
