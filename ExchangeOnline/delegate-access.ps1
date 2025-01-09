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

# Fetch all mailboxes
$mailboxes = Get-Mailbox -ResultSize Unlimited

# Create a runspace pool to run queries in parallel
$runspacePool = [runspacefactory]::CreateRunspacePool(1, [Environment]::ProcessorCount)
$runspacePool.Open()

$runspaces = @()
$delegateAccessResults = @()

# Iterate over each mailbox and create a runspace for each
foreach ($mailbox in $mailboxes) {
    $runspace = [powershell]::Create().AddScript({
        param($mailbox, $username)

        # Get mailbox permissions in bulk and filter for the desired user
        $permissions = Get-MailboxPermission -Identity $mailbox.PrimarySmtpAddress
        $delegates = $permissions | Where-Object {
            $_.User -like $username -and $_.AccessRights -contains "FullAccess"
        }

        # Return matching results
        if ($delegates) {
            $delegates | Select-Object -Property @{Name = 'Mailbox'; Expression = { $mailbox.PrimarySmtpAddress }},
                                                   @{Name = 'Delegate'; Expression = { $username }},
                                                   @{Name = 'Access'; Expression = { $_.AccessRights -join ", " }}
        }

    }).AddArgument($mailbox).AddArgument($username)

    # Assign runspace to the pool
    $runspace.RunspacePool = $runspacePool
    $runspaces += [PSCustomObject]@{ Pipe = $runspace; Status = $runspace.BeginInvoke() }
}

# Wait for all runspaces to finish and collect results
$runspaces | ForEach-Object {
    $_.Pipe.EndInvoke($_.Status)
    $delegateAccessResults += $_.Pipe.Streams.Output
    $_.Pipe.Dispose()
}

# Close the runspace pool
$runspacePool.Close()
$runspacePool.Dispose()

# Display results
if ($delegateAccessResults) {
    Write-Host "`n$username has delegate access on the following mailboxes:" -ForegroundColor Green
    $delegateAccessResults | Format-Table -AutoSize
} else {
    Write-Host "`nNo delegate access found for $username." -ForegroundColor Yellow
}

# Disconnect Exchange Online
Disconnect-ExchangeOnline -Confirm:$false
