##DHCP Migration with netsh

#region - Legacy migration with Netsh
	#Document Settings
	Invoke-Command -ComputerName Ocl1 {
		Get-DhcpServerSetting | fl
		Get-DhcpServerv4Scope | fl 
		Get-DhcpServerv4Policy | fl 
		Get-DhcpServerv4Superscope | fl 
		Get-DhcpServerv6Scope | fl 
		} | out-file c:\scripts\docdhcp. txt
		notepad c:\scripts\docdhcp. txt

	#verify DHCP Server Service is installed on Remote System
	Get-DhcpServerSetting -ComputerName S1

	#export configuration on Dc1
	Enter-PSSession -ComputerName Dc1
		netsh dhcp server export C:\dhcp-cfg.txt
		get-item c:\dhcp-cfg.txt
		Copy-Item `
			-Path \\dcl\c$\dhcp-cfg.txt `
			-Destination \\s1\c$\dhcp-cfg. txt
		Exit

	#Import Configuration on s1
	Enter-PSSession -ComputerName s1
		get-item c:\dhcp-cfg. txt
		Stop-service DHCPserver
		Del c:\windows\system32\DHCP\DHCP. mdb
		Start-service DHCPserver
		Netsh DHCP Server Import c:\dhcp-cfg.txt
		restart-service DHCPserver
		Evit

	#Import Configuration on S1
	Enter-PSSession -ComputerName s1
		get-item c:\dhcp-cfg.txt
		Stop-service DHCPserver
		Del c:\windows\system32\DHCP\DHCP. mdb
		Start-service DHCPserver
		Netsh DHCP Server Import c:\dhcp-cfg.txt
		restart-service DHCPserver
	Exit

	#verify
	Get-DhcpServerSetting -ComputerName s1 | fl
	Get-DhcpServerv4Scope -ComputerName s1 | fl
	Get-DhcpServerv4Policy -ComputerName s1 | fl
	Get-DhcpServerv4Superscope -ComputerName s1 | fl
	Get-DhcpServerv4Lease -ComputerName s1 -ScopeId 192.168.3.0 | ft
	Get-DhcpServerv6Scope -ComputerName s1 | ft