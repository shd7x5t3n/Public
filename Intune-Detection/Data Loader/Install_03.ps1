# Enable strict error handling
$ErrorActionPreference = "Stop"

try {
    # Paths
    $programPath = ${env:ProgramFiles(x86)} 
    $dataloaderPath = "$programPath\Salesforce Dataloader"
    $versionFolder = "$dataloaderPath\v63.0.0"
    $zipFilePath = "$PSScriptRoot\sf-dataloader-63.0.0.zip"
    $dataloaderBatPath = "$versionFolder\install.bat"
    $iconPath = "$versionFolder\dataloader.ico"
    $startMenuPath = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Salesforce Dataloader"
    $shortcutPath = "$startMenuPath\Salesforce Dataloader v63.0.0.lnk"

    # Ensure target folder exists
    if (-not (Test-Path $versionFolder)) {
        New-Item -Path $versionFolder -ItemType Directory -Force | Out-Null
    }

    # Extract ZIP only if required
    if (-not (Test-Path "$versionFolder\install.bat")) {
        if (-not (Test-Path $zipFilePath)) {
            Write-Host "ZIP file not found: $zipFilePath"
            exit 1
        }
        Expand-Archive -Path $zipFilePath -DestinationPath $versionFolder -Force
    }

    # Set permissions for 'Users' if not already applied
    $Acl = Get-Acl -Path $versionFolder
    $existingRule = $Acl.Access | Where-Object { $_.IdentityReference -match "Users" -and $_.FileSystemRights -eq "FullControl" }

    if (-not $existingRule) {
        $Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("Users", "FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")
        $Acl.SetAccessRule($Ar)
        Set-Acl -Path $versionFolder -AclObject $Acl
    }

    # Ensure Start Menu folder exists
    if (-not (Test-Path $startMenuPath)) {
        New-Item -Path $startMenuPath -ItemType Directory -Force | Out-Null
    }

    # Create shortcut only if missing
    if (-not (Test-Path $shortcutPath)) {
        $WshShell = New-Object -ComObject WScript.Shell
        $shortcut = $WshShell.CreateShortcut($shortcutPath)
        $shortcut.TargetPath = $dataloaderBatPath
        $shortcut.IconLocation = $iconPath
        $shortcut.Save()
    }

    Write-Host "Script executed successfully."
    exit 0  # Success
}
catch {
    Write-Host "Error: $($_.Exception.Message)"
    exit 1  # Failure
}
