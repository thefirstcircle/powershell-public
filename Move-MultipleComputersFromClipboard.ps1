#For moving multiple computers from a clipboard selection to a particular OU, then renaming them based on AD extended attributes and technician initials, date, etc.
#Example: if you want to move 200 computers to an imaging OU, the script will move them and name them based on this convention: "Contoso Headquarters Imaging Dell XPS 15 10/11/21 SJO"
#For this script to make sense, your organization needs to use AD extended attributes 4 and 11 for 'assigned user' and 'computer model', respectively.
#All environments will vary so modify as needed. Input the location at line 48.
#There are -Confirm arguments so you can proof the new description before making actual changes, per-computer.

#Limitations: 
#The "OU browser" is locked at 3 levels down. Change to suit your needs, or use the Read-Host that is commented out and input the OU manually.
#Running the script without the -Confim arguments is not recommended.

#In Microsoft Excel or similar, select the computers you want to move and copy to clipboard. Paste is not required. Run the script immediately after pasting.

#Steve O'Neill 2020

Start-Transcript

Write-Host "Warning: this is not a tool for L1/L2 staff. This script moves computers from OUs and renames them based on AD extended attributes. Consult your system administrator before use."
Write-Host "Copy any column from Excel." -ForegroundColor Yellow
$Date = Get-Date -Format "MM/dd/yy"
$Values = (Get-Clipboard) -split '\t|\r?\n' 
if($Values[$Values.count-1] -eq ""){$maxrawrow = $Values.count-2} else{$maxrawrow = $Values.count-1}
$Values = $Values[0..$maxrawrow]
$TechnicianInitials = Read-Host "Enter your initials"

Foreach ($item in $values){
Write-Host "Result for ""$item""" -ForegroundColor Magenta
Get-ADComputer $item}

Write-Host "In total, you made"$values.Count"selections. To move these PCs to a different OU, use the Move-ADComputer function."

function Move-ADComputer {
    Write-Host "Select the target OU" -ForegroundColor Magenta
    $ParentOU = Get-ADOrganizationalUnit -LDAPFilter '(name=*)' -SearchBase 'OU=Computers,OU=Clients,OU=AdminFin,DC=campus,DC=ads,DC=umass,DC=edu' -SearchScope OneLevel | Select-Object Name,DistinguishedName | Out-GridView -PassThru -Title "Parent OUs [press enter to select]"
    $DeptOU = Get-ADOrganizationalUnit -LDAPFilter '(name=*)' -SearchBase $ParentOU.DistinguishedName -SearchScope OneLevel | Select-Object Name,DistinguishedName | Out-GridView -PassThru -Title "Department OUs [press enter to select]"
    $DeptChildOU = Get-ADOrganizationalUnit -LDAPFilter '(name=*)' -SearchBase $DeptOU.DistinguishedName -SearchScope OneLevel | Select-Object Name,DistinguishedName | Out-GridView -PassThru -Title "Department Child OUs [press enter to select]"
    #$DeptChildOU = Read-Host "Enter the OU manually here, e.g. "OU=AsiaPacific,OU=Sales,OU=Computers,DC=FABRIKAM,DC=COM""

    $Confirmation = Read-Host "Target OU is $DeptChildOU. Confirm? Y/N"
    if ($Confirmation -eq 'Y'){
   
       foreach ($item in $values){
            $ADResult = Get-ADComputer $item -Properties Name,CanonicalName,Description,extensionAttribute11,extensionAttribute4,MemberOf
            $ShortName = $ADResult.Name
            $OriginalOU = $ADResult.CanonicalName
            $Description = $ADResult.Description
            $Model = $ADResult.extensionAttribute11
            $User =  $ADResult.extensionAttribute4
            $MemberOf = $ADResult | ForEach-Object{$_.MemberOf | %{Get-AdObject $_ } } | Select Name | Out-String
            $Technician = $env:username
            $NewOU = $DeptChildOU.Name
            #Write your office location below:
            $NewDescription = "Contoso Headquarters $NewOU $Model $Date $TechnicianInitials"
            Write-Host "$ShortName will be moved to"$DeptChildOU.Name". Currently it is found at"$OriginalOU"" -ForegroundColor Magenta
            Write-Host "$ShortName currently has a description of:"
            Write-Host "$Description" -ForegroundColor Yellow
            Write-Host "It will be changed to:"
            Write-Host "$NewDescription" -ForegroundColor Yellow
            Write-Host "Currently it has these groups: $MemberOf"
            $MoveConfirmation = Read-Host "Proceed? Y/N"
            Write-Host "------------------------------------------"

            if ($MoveConfirmation -eq 'Y'){
                Set-ADComputer $ADResult -Description $NewDescription -Confirm
                Move-ADObject $ADResult -TargetPath $DeptChildOU.DistinguishedName -Confirm
            } else { break } 
            }
            } else { break }
            }
