# To get the list of Names
Get-windowsfeature -name *ad*


#Installing Adds
Install-windowsfeature AD-domain-services -IncludeAllSubFeature -IncludeManagementTools 
Import-Module ADDSDeployment


Install-ADDSForest
-CreateDnsDelegation:$false
-DatabasePath "C:\windows\NTDS"
-DomainMode "winThreshold"
-DomainName "spacex.com"
-DomainNetbiosName "SPACEX"
-ForestMode "winThreshold"
-InstallDns:$true
-LogPath "C:\windows\NTDS"
-NoReboootOnCompletion:$false
-SyslovPath "C:\windows\SYSVOL"
-Force:$true