# Function that checks whether a given string matches the common pattern of a valid email address, returning true if it does and false if it doesn't
function Validate-EmailAddress {
    param(
        [string]$email
    )

    if ($email -match "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$") {
        return $true
    } else {
        return $false
    }
}

# Function that  prompts the user for an email address input and ensures its validity by repeatedly requesting input until a valid email address format is provided, 
#offering a user-friendly way to collect valid email addresses in PowerShell scripts while providing error logging for invalid inputs.
function Get-ValidEmailInput {
    param(
        [string]$prompt
    )

    $email = $null
    while (-not (Validate-EmailAddress $email)) {
        $email = Read-Host $prompt
        if (-not (Validate-EmailAddress $email)) {
            Write-log "Invalid email address format. Please enter a valid email address." "ERROR"
        }
    }
    return $email
}

#Function that extracts the domain from an email address and checks if it belongs to a list of allowed domains,
#returning true if it's valid, making it useful for domain-based validation of email addresses.
function IsValidDomain($email, $allowedDomains) {
    $domain = $email.Split('@')[1]
    return $domain -in $allowedDomains
}

#Function thatprompts the user to input an email address while ensuring it is both non-empty and belongs to a list of allowed domains, 
#providing error messages and retries until a valid email address is provided.
function Get-ValidEmailInputWithDomainCheck($message, $allowedDomains) {
    $email = $null

    while ($email -eq $null -or -not (IsValidDomain $email $allowedDomains)) {
        $email = Get-ValidEmailInput $message

        if ($email -eq $null) {
            Write-Log "Email cannot be empty. Please enter a valid email address." "ERROR"
            continue
        }

        if (-not (IsValidDomain $email $allowedDomains)) {
            Write-Log "Invalid domain in email address. Allowed domains are: $($allowedDomains -join ', ')." "ERROR"
        }
    }

    return $email
}

# This function allows users to input two distinct email addresses (User Principal Names or UPNs) with optional domain validation.
# It ensures that both UPNs entered are not empty and different from each other, providing error messages and retries if needed.
# When $validationMethod is set to 1, it enforces input email addresses to belong to allowed domains specified in the $allowedDomains array.
# If $validationMethod is set to 0, it requires a valid email address format without domain restrictions.
function Get-UniqueEmailInputs {
    param (
        [int]$validationMethod = 0
    )

    if ($validationMethod -eq 0) {
        $upn1 = $null
        $upn2 = $null

        $upn1 = Get-ValidEmailInput "Enter the source username (e.g., user@example.com)"

        while ($upn1 -eq $null) {
            Write-Log "Source username cannot be empty. Please enter a valid username." "ERROR"
            $upn1 = Get-ValidEmailInput "Enter the source username (e.g., user@example.com)"
        }

        $upn2 = Get-ValidEmailInput "Enter the destination username (e.g., user@example.com)"

        while ($upn2 -eq $null) {
            Write-Log "Destination username cannot be empty. Please enter a valid username." "ERROR"
            $upn2 = Get-ValidEmailInput "Enter the destination username (e.g., user@example.com)"
        }

        while ($upn1 -eq $upn2) {
            Write-Log "Source and destination usernames cannot be the same. Please enter different usernames." "ERROR"
            $upn2 = Get-ValidEmailInput "Enter the destination username (e.g., user@example.com)"
        }
    }
    else {
        $allowedDomains = @("admin.test.com", "test.com")

        $upn1 = Get-ValidEmailInputWithDomainCheck "Enter the source username (e.g., user@$($allowedDomains[0]) or user@$($allowedDomains[1]))" $allowedDomains
        $upn2 = Get-ValidEmailInputWithDomainCheck "Enter the destination username (e.g., user@$($allowedDomains[0]) or user@$($allowedDomains[1]))" $allowedDomains

        while ($upn1 -eq $upn2) {
            Write-Log "Source and destination usernames cannot be the same. Please enter different usernames." "ERROR"
            $upn2 = Get-ValidEmailInputWithDomainCheck "Enter the destination username (e.g., user@$($allowedDomains[0]) or user@$($allowedDomains[1]))" $allowedDomains
        }
    }

    return $upn1, $upn2
}
