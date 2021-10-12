#This script backs a .WIM file up to a remote drive.
#Intended only to be used with a WinPE boot stick containing the WinPE-PowerShell and WinPE-SecureStartup optional components
#Network needs to be initialized and drivers need to be loaded on the client computer (being imaged).
#This script must be loaded on the WinPE boot stick and called from startnet.cmd
#Steve O'Neill 2019

$ServerShare = \\0.0.0.0\WIM_Backups
$ServerLogPath = \\0.0.0.0\WIM_Backup_Logs
New-PSDrive -Name "P" -PSProvider FileSystem -Root $ServerShare -ErrorAction Suspend

#Consider using a barcode scanner & 2D barcode for this step
$BitlockerKey = Read-Host "Enter Bitlocker Key"

$Date = (Get-Date -Format yyyy-MM-dd-ss)
$ComputerModel = (Get-ComputerInfo -Property CSSystemFamily).CsSystemFamily
#$ImagePath = Read-Host "Enter ImagePath" ## this is going to be wherever we store the final clone
$ImagePath = $ServerShare
$MACAddresses = (Get-NetAdapter).MacAddress -join ','
#Exclude any disks and volumes that are not fixed (permanent), such as WinPE partitions or other removeable media:
$FixedDisk = (Get-CimInstance -Class Win32_DiskDrive -Filter 'MediaType = "Fixed hard disk media"' -KeyOnly | Get-CimAssociatedInstance -ResultClassName Win32_DiskPartition -KeyOnly | Get-CimAssociatedInstance -ResultClassName Win32_LogicalDisk).DeviceID

Foreach ($DriveLetter in $FixedDisk) {
    Manage-BDE -unlock $DriveLetter -recoverypassword $BitlockerKey 
    Write-Host "Loading the registry hive"
    Reg load HKLM\TempHive $DriveLetter\Windows\System32\Config\SYSTEM
    Write-Host "Getting the computer name..."
    $ComputerName = (Get-ItemProperty HKLM:\TempHive\ControlSet001\Control\ComputerName\ComputerName).ComputerName
    Write-Host "The computer name is $ComputerName"
	Write-Host "Unloading the registry hive..."
	Reg unload HKLM\TempHive
    [gc]::Collect()
    Start-Sleep 5
    
    #Export the partition to a .WIM file:
    New-WindowsImage -ImagePath $ImagePath\$Date-$ComputerName.wim -CapturePath $FixedDisk -Name "$Date-ComputerName" -ErrorAction Inquire -loglevel WarningsInfo -LogPath $ImagePath\Log
    #Optional alternative to New-WindowsImage (itself just an alias):
    #DISM /capture-image /imagefile:$ImagePath\$Date-$ComputerName.WIM /capturedir:$DriveLetter /name:$Date-$ComputerName

    #Logging:
    $Users = @((Get-ChildItem -Path "C:\Users" | Select-Object -Property Name).Name) -join ','
    $Properties = @(
        [pscustomobject]@{
            Date = $Date
            ComputerName = $ComputerName
            ComputerModel = $ComputerModel
            FixedDisk = $FixedDisk
            ImagePath = $ImagePath
            Users = $Users
            MACAddresses = $MACAddresses

    }

$Properties | Export-Csv $ServerLogPath\WIMBackupLog.csv -Append -NoTypeInformation -NoClobber