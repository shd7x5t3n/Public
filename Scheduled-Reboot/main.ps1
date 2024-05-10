# Get last reboot time
$os = Get-WmiObject Win32_OperatingSystem
$lastBootUpTime = $os.ConvertToDateTime($os.LastBootUpTime)

# Calculate days since last reboot
$currentDateTime = Get-Date
$daysSinceLastReboot = ($currentDateTime - $lastBootUpTime).Days
Write-Output "Days since last reboot: $daysSinceLastReboot"

# Check if last reboot was more than 7 days ago
if ($daysSinceLastReboot -gt 7) {
    Write-Output "Last reboot was more than 7 days ago."

    # Calculate the next 10 PM
    $nextRebootTime = Get-Date -Hour 22 -Minute 0 -Second 0
    if ($nextRebootTime -lt $currentDateTime) {
        $nextRebootTime = $nextRebootTime.AddDays(1)
    }

    # Create a new scheduled task to reboot at the next 10 PM
    $action = New-ScheduledTaskAction -Execute 'shutdown.exe' -Argument '/r /t 0'
    $trigger = New-ScheduledTaskTrigger -Once -At $nextRebootTime
    $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
    $task = New-ScheduledTask -Action $action -Trigger $trigger -Principal $principal -Description "Reboot at 10 PM" -TaskName "Scheduled Reboot"
    Register-ScheduledTask -Task $task

    Write-Output "Scheduled task 'Scheduled Reboot' created to reboot at 10 PM."
} else {
    Write-Output "Last reboot was not more than 7 days ago. No action required."
}
