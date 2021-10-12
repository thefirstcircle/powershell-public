#Checks User accounts for the "Log On To" field & gives a summary of associated workstations that no longer have AD objects.
#The "Log On To" field in Active Directory only stores strings, not references to actual AD objects. Therefore clean-up is sometimes necessary.
#For example, if 'generic_user_account' is set to only log onto Computer-123456, but that computer was decommissioned, this will generate a report telling you so.

$Report = $null
$Date = Get-Date -f yyy-MM-dd-ss
$LogPath = "C:\Users\YourName\Documents\LogonWorkstations-$Date.csv"
$OU = "OU=AsiaPacific,OU=Sales,OU=Users,DC=FABRIKAM,DC=COM"
$FinalReport = @()
$Accounts = (Get-ADUser -Filter * -SearchBase $OU -Properties LogonWorkstations) | Where-Object {$_.LogonWorkstations -ne $null}
Foreach ($Account in $Accounts) {

    $AuthorizedComputers = $Account.LogonWorkstations.Split(",")
    Foreach ($AuthorizedComputer in $AuthorizedComputers){
            $LogonWorkstationsActiveInAD = ""
        $LogonWorkstationsNotFound = ""

       try (Get-ADComputer -Identity $AuthorizedComputer) {$LogonWorkstationsActiveInAD = $AuthorizedComputer} catch { $PSObject. }

        Write-Host $Account -ForegroundColor Magenta
        Write-Host $AuthorizedComputer -ForegroundColor Green


    $Report= @(
    [pscustomobject]@{
    Account = $Account
    LogonWorkstationsActiveInAD = $LogonWorkstationsActiveInAD
    LogonWorkstationsNotFound = $LogonWorkstationsNotFound
    }
    ) 

$FinalReport += $Report
}
}