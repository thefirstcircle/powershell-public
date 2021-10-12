## This script backs a .WIM file up to a remote drive.
It's ntended only to be used with a WinPE boot stick containing the WinPE-PowerShell and WinPE-SecureStartup optional components. Instructions for manually creating a WinPE boot stick are below.

[Using WinPE and startnet.cmd](https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/wpeinit-and-startnetcmd-using-winpe-startup-scripts)

## Copy WinPE onto a local directory:
	copype amd64 C:\WinPE_amd64_PS2

## Mount the image:
	Dism /Mount-Image /ImageFile:"C:\WinPE_amd64_PS2\media\sources\boot.wim" /Index:1 /MountDir:"C:\WinPE_amd64_PS2\mount"

## Add packages:
	Dism /Add-Package /Image:"C:\WinPE_amd64_PS2\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-WMI.cab"
	Dism /Add-Package /Image:"C:\WinPE_amd64_PS2\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-WMI.cab"
	Dism /Add-Package /Image:"C:\WinPE_amd64_PS2\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-WMI_en-us.cab"
	Dism /Add-Package /Image:"C:\WinPE_amd64_PS2\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-NetFX.cab"
	Dism /Add-Package /Image:"C:\WinPE_amd64_PS2\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-NetFX_en-us.cab"
	Dism /Add-Package /Image:"C:\WinPE_amd64_PS2\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-Scripting.cab"
	Dism /Add-Package /Image:"C:\WinPE_amd64_PS2\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-Scripting_en-us.cab"
	Dism /Add-Package /Image:"C:\WinPE_amd64_PS2\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-PowerShell.cab"
	Dism /Add-Package /Image:"C:\WinPE_amd64_PS2\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-PowerShell_en-us.cab"
	Dism /Add-Package /Image:"C:\WinPE_amd64_PS2\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-StorageWMI.cab"
	Dism /Add-Package /Image:"C:\WinPE_amd64_PS2\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-StorageWMI_en-us.cab"
	Dism /Add-Package /Image:"C:\WinPE_amd64_PS2\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-DismCmdlets.cab"
	Dism /Add-Package /Image:"C:\WinPE_amd64_PS2\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-DismCmdlets_en-us.cab"
	Dism /Add-Package /Image:"C:\WinPE_amd64_PS2\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\WinPE-SecureStartup_en-us.cab"
	Dism /Add-Package /Image:"C:\WinPE_amd64_PS2\mount" /PackagePath:"C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64\WinPE_OCs\en-us\WinPE-SecureStartup_en-us.cab"

## Modify startnet.cmd (or copy the one in this directory over)
	C:\WinPE_amd64\mount\Windows\System32\Startnet.cmd

## Commit changes to your WinPE image:
	
	Dism /Unmount-Image /MountDir:C:\WinPE_amd64_PS2\mount /Commit

## Create the WinPE bootable USB drive [P: is the drive letter of the USB stick]:
	MakeWinPEMedia /UFD C:\WinPE_amd64_PS2 P:

https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/winpe-create-usb-bootable-drive