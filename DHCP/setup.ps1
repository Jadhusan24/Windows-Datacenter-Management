#Rename Server
Rename-Computer -NewName core021

#check the adapter
Get-NetAdapter

#Assign Ip Address
New-NetIPAddress -InterfaceIndex 4 -IPAddress 10.10.10.10 -prefixLength 24 -DefaultGateway 10.10.10.1
set-DnsClientServerAddress -InterfaceIndex 4 -ServerAddresses 10.10.10.10
ipconfig /all
#-----------------------------------------------------------------------------------------------------------------------------------------------------


#restart server
Restart-Computer

#-----------------------------------------------------------------------------------------------------------------------------------------------------

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


#-----------------------------------------------

#creating dhcp
Add-WindowsFeature –IncludeManagementTools DHCP
Get-Command -Module DHCPServer


#Create the security groups:
Netsh DHCP Add SecurityGroups
Add-DhcpServerSecurityGroup

#Restart the service. 
Restart-Service DHCPServer

#Authorize the DHCP server in AD DS:
Add-DHCPServerinDC 192.168.8.10


#Add DHCP Scope
Add-DhcpServerV4Scope -Name "Scope 1" -StartRange 192.168.8.100 -EndRange 192.168.8.200 -SubnetMask 255.255.255.0

Set-DhcpServerV4OptionValue -DnsServer 192.168.8.10 -Router 192.168.8.1
Set-DhcpServerv4Scope -ScopeId 192.168.8.0 -LeaseDuration 1.00:00:00

#-------------------------------------------------------------------------------------

#firewall rules
set-netfirewallrule –name complusnetworkaccess-dcom-in –enabled true
set-netfirewallrule –name remoteeventlogsvc-in-tcp –enabled true
set-netfirewallrule –name remoteeventlogsvc-np-in-tcp –enabled true
set-netfirewallrule –name remoteeventlogsvc-rpcss-in-tcp –enabled true