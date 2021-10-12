# This script searches Windows firewall GPOs for hostnames which do not resolve. This may be useful for those who clean up group policy on a routine basis.
# Steve O'Neill 2020

#Back up the firewall GPO to an XML and import (change path to suit your needs):
[xml]$GPReport = Get-Content -path C:\Users\Public\Documents\gpreport.xml

#Search inbound rules for dead IPs:
$GPReport.GPO.Computer.ExtensionData.Extension.InboundFirewallRules | ForEach-Object {
    $IPAddressArray = @()
    $RuleIPAddresses = $_.RA4
        foreach ($RuleIPAddress in $RuleIPAddresses){ try 
            {$IPAddressArray += [System.Net.Dns]::GetHostByAddress($RuleIPAddress).HostName} catch { 
                if ($($PSItem.ToString()) -match "data"){$NonResolve = "Yes"} else {$IPRange = "Yes"}}

         ## output the result object
        [pscustomobject]@{
            Direction = $_.Dir 
            Action = $_.Action
            Rule = $_.Name
            NonResolvingValidAddress = $NonResolve
            IP_Range_Present = $IPRange
            Hostname = ($IPAddressArray -join ", ")
            IP = $_.RA4
        }
        $RuleIPAddresses = $null
        $RuleIPAddress = $null
        $NonResolve = $null
        $IPRange = $null
    }
    $IPAddressArray = $null 
} | Out-GridView

#Search outbound rules for dead IPs:
$GPReport.GPO.Computer.ExtensionData.Extension.OutboundFirewallRules | ForEach-Object {
    $IPAddressArray = @()
    $RuleIPAddresses = $_.RA4
        foreach ($RuleIPAddress in $RuleIPAddresses){ try 
            {$IPAddressArray += [System.Net.Dns]::GetHostByAddress($RuleIPAddress).HostName} catch { 
                if ($($PSItem.ToString()) -match "data"){$NonResolve = "Yes"} else {$IPRange = "Yes"}}

         ## output the result object
        [pscustomobject]@{
            Direction = $_.Dir 
            Action = $_.Action
            Rule = $_.Name
            NonResolvingValidAddress = $NonResolve
            IP_Range_Present = $IPRange
            Hostname = ($IPAddressArray -join ", ")
            IP = $_.RA4
        }
        $RuleIPAddresses = $null
        $RuleIPAddress = $null
        $NonResolve = $null
        $IPRange = $null
    }
    $IPAddressArray = $null 
} | Out-GridView


#Find IPs by regex: Select-String -Pattern "\d{1,3}(\.\d{1,3}){3}" -AllMatches).Matches.Value

#Example of dead IP you might see. The term "data" is searched for because the .NET error message for an nslookup contains that word, unlike other error messages.
#try {
#    [System.Net.Dns]::GetHostByAddress("192.168.100.10").HostName
#    } catch {
#        if ($($PSItem.ToString()) -match "data"){Write-Host "Could not resolve hostname :/"}else{"Some other error occurred"}
#    }

#Example of an IP range that we're not interested in, same logic:
#try {
#    [System.Net.Dns]::GetHostByAddress("192.168.20.0/255.255.255.0").HostName
#    } catch {
#        if ($($PSItem.ToString()) -match "data"){Write-Host "Could not resolve hostname :/"}else{"Some other error occurred; is this an IP range?"}
#    }