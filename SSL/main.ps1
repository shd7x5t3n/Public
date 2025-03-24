# Ensure PowerShell is running as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "This script must be run as Administrator!" 
    exit
}

# Define certificate parameters
$dnsName = [System.Net.Dns]::GetHostEntry($env:COMPUTERNAME).HostName
$certStore = "Cert:\LocalMachine\My"
$tempFolderPath = "C:\CertTemp"

# Ensure the temporary folder exists
if (-not (Test-Path $tempFolderPath)) {
    New-Item -ItemType Directory -Path $tempFolderPath -Force | Out-Null
}

# Generate the self-signed certificate
$cert = New-SelfSignedCertificate `
    -DnsName $dnsName.ToUpper() `
    -CertStoreLocation $certStore `
    -KeyAlgorithm RSA `
    -KeyLength 4096 `
    -HashAlgorithm SHA256 `
    -KeyUsage DigitalSignature, KeyEncipherment `
    -TextExtension "2.5.29.37={text}1.3.6.1.5.5.7.3.1" `
    -NotAfter (Get-Date).AddYears(1)

# Set the friendly name
(Get-Item "$certStore\$($cert.Thumbprint)").FriendlyName = "SQL SSL Cert"

# Format thumbprint: remove spaces and convert to uppercase
$formattedThumbprint = ($cert.Thumbprint -replace '\s', '').ToUpper()

# Define registry path information in a hashtable array
$registrySettings = @(
    @{
        "Path" = "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL14.GOLDENRESOURCES\MSSQLServer\SuperSocketNetLib"
        "Name" = "Certificate"
        "Value" = $formattedThumbprint
        "Type" = "String"
    }
)

# Ensure the registry path exists, create if missing
foreach ($setting in $registrySettings) {
    if (-not (Test-Path $setting["Path"])) {
        New-Item -Path $setting["Path"] -Force | Out-Null
    }

    # Update registry with the formatted thumbprint
    Set-ItemProperty -Path $setting["Path"] -Name $setting["Name"] -Value $setting["Value"] -Type $setting["Type"]
}

# Export the certificate to a temporary file (DER format)
$exportPath = "$tempFolderPath\SQLCert.cer"
Export-Certificate -Cert "$certStore\$($cert.Thumbprint)" -FilePath $exportPath

# Import the certificate into the Trusted Root Certification Authorities store
if (Test-Path $exportPath) {
    Import-Certificate -FilePath $exportPath -CertStoreLocation "Cert:\LocalMachine\Root"
    Write-Output "Certificate successfully imported to Trusted Root Certification Authorities."
} else {
    Write-Error "Failed to locate the exported certificate file."
}

# Clean up the temporary exported certificate file
Remove-Item -Path $exportPath -Force

Write-Output "Certificate creation, registry update, and import completed."
