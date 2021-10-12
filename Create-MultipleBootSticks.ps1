# This script scans for locally connected USB drives, formats them, and copies boot files over from a network share to a temp directory, deleting it after.
# There is no limit on USB drives and there is less risk of writing the files files to a system or network drive. 
# The user will be prompted if there are USB drives bigger than 8GB present, in case there are USB hard drives attached.
# Steve O'Neill 5/23/19

$BootFilesDirectory = "\\server\your-boot-file-directory"
$TempDirectory = "$env:TEMP\Boot Files"

$StartConfirmation = Read-Host "CAUTION! All USB removeable media will be overwritten. Are you sure you want to proceed? [Y/N]"
if ($StartConfirmation -eq 'Y') {
    Write-Host "Copying boot files from network location..."
    ROBOCOPY "$BootFilesDirectory" "$TempDirectory" /mir /np /log+:$env:TEMP\RobocopyToTempDirLog.txt | Out-Null
    $USBDriveList = (Get-CimInstance -Class Win32_DiskDrive -Filter 'InterfaceType = "USB"' -KeyOnly)
    
    Foreach ($PhysicalUSB in $USBDriveList) {
            $PhysicalUSBSize = $PhysicalUSB.Size/1GB
            if ($PhysicalUSB.Size -ige 8000000000) { $BigDiskConfirmation = (Read-Host "$($PhysicalUSB.Model) is $($PhysicalUSBSize.ToString(".00")) gigabytes. Are you sure you want to continue? [Y/N]") 
                if ($BigDiskConfirmation -ne 'Y') { throw }
                }
            }

    $USBDriveNumber = $USBDriveList.index
    Write-Host "Formatting USB drives..."
    Foreach ($USBDrive in $USBDriveNumber)
        {
        Clear-Disk -number $USBDRive -removedata -removeOEM -Confirm:$false | Out-Null
        New-Partition –DiskNumber $USBDrive -AssignDriveLetter –UseMaximumSize –IsActive:$true -MbrType FAT32 -ErrorVariable PartitionError | Format-Volume -FileSystem FAT32 | Out-Null
        if ($PartitionError){
            Write-Host "There was an issue creating a partition on $USBDrive. Attempting to convert it to MBR..."
            #Creates a .txt file to use Diskpart scripting. As of now there are no PS cmdlets that can convert GPT to MBR or vice-versa.
            New-Item -name $env:TEMP\convertmbr.txt -ItemType file -Force -ErrorAction SilentlyContinue| Out-Null
            Add-Content -Path $env:TEMP\convertmbr.txt "select disk $USBDrive"
            Add-Content -Path $env:TEMP\convertmbr.txt "convert mbr"
            DiskPart /s "$env:TEMP\convertmbr.txt"
            New-Partition –DiskNumber $USBDrive -AssignDriveLetter –UseMaximumSize –IsActive:$true -MbrType FAT32 | Format-Volume -FileSystem FAT32 | Out-Null
           }
        }

    Write-Host "Setting the drive mappings..."
    $USBDriveMappings = ($USBDriveList | Get-CimAssociatedInstance -ResultClassName Win32_DiskPartition -KeyOnly | Get-CimAssociatedInstance -ResultClassName Win32_LogicalDisk)
    $driveletter = $USBDriveMappings.DeviceID
        Foreach ($item in $driveletter)
        {
            Write-Host "Copying the KACE boot files to '$item'..."
            ROBOCOPY "$TempDirectory" "$item" /mir /np /log+:$env:TEMP\RobocopyToDriveLog.txt | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "Successfully copied files to $item"
                } else {
                Write-Host "Robocopy completed with exit code: $LASTEXITCODE"
                }
        }

    Write-Host "Removing the boot files from the user's temp directory..."
    Remove-Item "$env:TEMP\Boot Files" -Recurse -Force
    Remove-Item "$env:TEMP\convertmbr.txt" -Force -ErrorAction SilentlyContinue

    $LogViewConfirmation = Read-Host "Complete. Logs were created in $env:TEMP. View them now? [Y/N]"
    if ($LogViewConfirmation -eq 'Y') {
        notepad.exe "$env:TEMP\RobocopyToTempDirLog.txt"
        notepad.exe "$env:TEMP\RobocopyToDriveLog.txt"
        }

} else {
Write-Host "Cancelled"
}
