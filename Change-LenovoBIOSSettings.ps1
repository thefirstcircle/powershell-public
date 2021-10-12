# This script disables PXE network booting and Intel AMT in the BIOS on Lenovo ThinkPads (and hopefully other brands, eventually)
# Steve O'Neill 2020

$ManufacturerCheck = (Get-ComputerInfo -Property CsManufacturer)
$LaptopCheck = (Get-WmiObject -Class win32_systemenclosure).chassistypes

#Determine if the device is a laptop (codes 9, 10, and 14 are Laptop, Notebook, and Sub-Notebook):
Switch ($LaptopCheck)
{
    9 {$IsLaptop = $true}
    10 {$IsLaptop = $true}
    14 {$IsLaptop = $true}
}

if ($ManufacturerCheck.CsManufacturer -like "LENOVO" -and $IsLaptop -eq $true) { 
   
    $AppliedBIOSFeatures = @()
    
    #Define the features you want to adjust (IPv4NetworkStack & IPv6NetworkStack only affect network funcitonality inside PXE)
    $BIOSFeatures = @(
    "WakeOnLAN",
    "WakeOnLANDock",
    "EthernetLANOptionROM",
    "IPv4NetworkStack",
    "IPv6NetworkStack",
    "AMTControl")

    $Action = "Disable"
    #$Action = "Enable"

    Write-Host "The following BIOS features will be set to ""$($Action)"":" -ForegroundColor Magenta
    Write-Host @BIOSFeatures -Separator "`n"

    foreach ($Feature in $BIOSFeatures) {
        $ChangeSetting = (Get-WmiObject -class Lenovo_SetBiosSetting -namespace root\wmi).SetBiosSetting("$Feature,$Action")
        if ($ChangeSetting.return -notlike "Success") {
            Write-Host "There was a problem setting $Feature to the following setting: $Action. The return code is: $($ChangeSetting.return)" -ForegroundColor Magenta
        } else {
            $AppliedBIOSFeatures += $Feature
        }
    } 

    $Confirmation = (Read-Host "Do you want to continue with saving these settings? Y/N")
    if ($Confirmation -eq "Y") {
    $ApplySetting = (Get-WmiObject -class Lenovo_SaveBiosSettings -namespace root\wmi).SaveBiosSettings()
        if ($ApplySetting.return -like "Success") {
            Write-Host "The following BIOS features were set to ""$($Action)"":" -ForegroundColor Yellow
            Write-Host @AppliedBIOSFeatures -Separator "`n"
    } else {break}
    }
}