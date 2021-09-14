##DHCP Migration with powershell

#region - Legacy migration with Netsh...

#region -Migrating an Existing Configuration from One Server to Another
	#Verify DHCP Server Service is installed on Remote System
	Get-DhcpServerSetting -ComputerName S1
	Get-DhcpServerv4Scope -computername s1

	#Document Settings
	Invoke-Command -ComputerName DC1 {
		Get-DhcpServersetting | fl
		Get-DhcpServerv4Scope | FL
		Get-DhcpServerv6Scope | Fl
		Get-DhcpServerv4Policy | fl
		Get-DhcpServerv4Superscope | fl
		} | out-file ¢:\docdhcp. txt
	notepad c:\docdhcp. txt

	#Create Backup Folder on Admin workstation
	New-Item -ItemType directory -Path c:\DHCPMigration

	#Review Help file for examples
	Help Export-DHCPServer -Full

	#Single Scope with Leases
	Export-DHCPServer -ComputerNmae DC1 `
		-ScopeId 192.168.3.0 `
		-Leases `
		-File "c:\DHCPMigration\DHCPScopeExport.xml"
		-Verbose
		-Force

	c:\DHCPMigration\DHCPScopeExport.xml


	#Export Entire DHCP Server configuration with Leases
	Export-DhcpServer -ComputerName DC1 `
		-Leases `
		-File "c:\DHCPMigration\fulldhcpexport.xml" `
		-Verbose `
		-Force

	#Import Entire Server Configuration to s1
	Import-DhcpServer -ComputerName s1 `
		-File c:\DHCPMigration\fulldhcpexport.xml `
		-BackupPath c:\DHCPBackup `
		-Leases `
		-Verbose

	#Verify Scopes, Policies and Leases are moved to s1
	Get-DhcpServerSetting -ComputerName s1 | fl
	Get-DhcpServerv4Scope -ComputerName s1 | ft
	Get-DhcpServerv4Policy -ComputerName s1 | ft
	Get-DhcpServerv4Superscope -ComputerName s1 | ft
	Get-DhcpServerv4Lease -ComputerName s1 -ScopeId 192.168.3.0 | ft
	Get-DhcpServerv6Scope -ComputerName s1 | ft

	#Verify CL2 gets ip from new dhcpServer
	Invoke-Command -ComputerName DC1 {stop-service DHCPServer}

	#Decommission DC1
	Remove-DhcpServerInDC -DnsName DC1.company.pri
	Get-DhcpServerInDC
	Invoke-Command -ComputerName DC1 {stop-service DHCPServer}
	Remove-WindowsFeature -Name DHCP -ComputerName DC1 -Restart
	invoke-command -computerName DC1{
		Remove-Item -Path c:\windows\system32\dhcp -Recurse -Verbose
		}

#endregion