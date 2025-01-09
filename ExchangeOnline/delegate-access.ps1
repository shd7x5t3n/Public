# Connect to Exchange Online
$session = Connect-ExchangeOnline -ShowProgress $true

# Prompt user for input
$username = Read-Host -Prompt "Enter the username to check delegate access (e.g., user@example.com)"

# Validate user input
if ([string]::IsNullOrWhiteSpace($username)) {
    Write-Host "Invalid input. Exiting script." -ForegroundColor Red
    Disconnect-ExchangeOnline -Confirm:$false
    return
}

# Fetch all mailboxes and filter delegate access
$delegateAccessResults = Get-Mailbox -ResultSize Unlimited | ForEach-Object {
    $mailbox = $_
    Get-MailboxPermission -Identity $mailbox.PrimarySmtpAddress | Where-Object {
        $_.User -like $username -and $_.AccessRights -contains "FullAccess"
    } | Select-Object -Property @{
        Name  = 'Mailbox'; Expression = { $mailbox.PrimarySmtpAddress }
    }, @{
        Name  = 'Delegate'; Expression = { $username }
    }, @{
        Name  = 'Access'; Expression = { $_.AccessRights -join ", " }
    }
}

# Display results
if ($delegateAccessResults) {
    Write-Host "`n$username has delegate access on the following mailboxes:" -ForegroundColor Green
    $delegateAccessResults | Format-Table -AutoSize
} else {
    Write-Host "`nNo delegate access found for $username." -ForegroundColor Yellow
}

# Disconnect Exchange Online
Disconnect-ExchangeOnline -Confirm:$false
