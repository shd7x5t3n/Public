# Path to the Windows Program Directory
$programPath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::ProgramFilesX86)


# Target Path for Salesforce Dataloader
$dataloaderPath = Join-Path -Path $programPath -ChildPath 'Salesforce Dataloader'

# Target Folder for Version 63.0.0
$versionFolder = Join-Path -Path $dataloaderPath -ChildPath 'v63.0.0'

# Check if the target folder already exists
if (-not (Test-Path -Path $versionFolder)) {
    # Path to the ZIP file
    $zipFilePath = Join-Path -Path $versionFolder -ChildPath 'sf-dataloader-63.0.0.zip'

    # Create the folder
    New-Item -Path $versionFolder -ItemType Directory -Force

    # Extract the ZIP file
    Expand-Archive -Path '.\sf-dataloader-63.0.0.zip' -DestinationPath $versionFolder -Force
}

# Set permissions for users in the target folder
$Acl = Get-Acl -Path $versionFolder
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule("Users", "FullControl", "ContainerInherit, ObjectInherit", "None", "Allow")
$Acl.SetAccessRule($Ar)
Set-Acl -Path $versionFolder -AclObject $Acl

# Path to the install.bat
$dataloaderBatPath = Join-Path -Path $versionFolder -ChildPath 'install.bat'

# Path to the custom icon
$iconPath = Join-Path -Path $versionFolder -ChildPath 'dataloader.ico'

# Target path for the Start Menu
$startMenuPath = [System.Environment]::GetFolderPath('CommonStartMenu')

# Name of the Shortcut
$shortcutName = 'Salesforce Dataloader v63.0.0'

# Path for the shortcut in the Start Menu
$shortcutPath = Join-Path -Path $startMenuPath -ChildPath ('Programs\Salesforce Dataloader\' + $shortcutName + '.lnk')

# Check if the shortcut already exists
if (-not (Test-Path -Path $shortcutPath)) {
    # Create folder in the Start Menu if not present
    $shortcutFolder = Join-Path -Path $startMenuPath -ChildPath 'Programs\Salesforce Dataloader'
    New-Item -Path $shortcutFolder -ItemType Directory -Force

    # Create the shortcut
    $WshShell = New-Object -ComObject WScript.Shell
    $shortcut = $WshShell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $dataloaderBatPath
    $shortcut.IconLocation = $iconPath

    $shortcut.Save()
}

exit 0
