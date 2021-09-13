# Im Using A Windows Server Core Machine and Using Windows 10 Pc with rsat tools
# ------------
# systeminfo

get-netadapters
New-NetIPAddress -InterfaceIndex 12 -IPAddress 192.168.3.200 -PrefixLength 24 -DefaultGateway 192.168.3.2
Set-DNSClientServerAddress -interfacealias ethernet0 -ServerAddress 192.168.3.10
New-NetFirewallRule -displayname "Allow All Traffic" -direction outbound -action allow
New-NetFirewallRule -displayname "Allow All Traffic" -direction inbound -action allow
hostname
Add-Computer -newname hyperv1 -domainname spacex.co -restart

# ==========================================================================================================================

# admin PC 
get-windowsfeature -computername hyperv1
install-windowsfeature -computername hyperv1 -name hyper-v
restart-computer -computername hyperv1
install-windowsfeature -computername hyperv1 -name rsat-hyper-v-tools
install-windowsfeature -computername hyperv1 -name hyper-v-powershell
#to check the features
get-windowsoptionalfeature -online
#to verify installation of hyper v
get-windowsoptionalfeature -online | where featurename -like "*hyper*"


# ==========================================================================================================================

# admin PC - hyperv VMS
New-VM -computername hyperv1 -name VM1 -generation 2 -memorystartupbytes 2gb -newVHDpath vm1.vhx -newVHDsizebytes 60000000000 -switchname -external
start-vm -computername hyperv1 -name vm1
get-vm -computername hyperv1

# ==========================================================================================================================

# Powershell Direct
# To work with a virtual machine setting on top of a hyperv-host
# for working with virtual machines that are on that specific hyper-v host

# Interatice Session
# EnterpsSession to directly enter in to remote session
Enter-PSsession -vmname nanoserver1
get-process

# ==========================================================================================================================

# Single-use Session
# excution of script or single line of command
invoke-command -vmname nanoserver 1 -scriptBlock { get-process }

# ==========================================================================================================================

# Persistent Session
# that you store in variable and make use of machine
$session = new-PSSession -vmname nanoserver1 -credential (get-credential)
copy-item -fromsession $session -path c:\nanoserver.txt -destination c:\

# ==========================================================================================================================

# Upgrade VM
get-vm
get-vm -computername hyperv1
get-vm -computername hyperv1 -name vm2 -version 7.0
update-vmversion -computername hyperv1 -name vm2

# Delegate VM
# ==========================================================================================================================
# JEA TOOL

Enter-PSSession hyperv1
	New-PSrolecapabilityfile -path ./rebootonly.psrc
	New-PSrolecconfigurationfile -path ./rebootonly.pssc -full

# NESTED
# ==========================================================================================================================
# hyperv vms inside hyperv vms

set-vmprocessor -vmname nanoserver1 -exposevirtualizationExtensions $true
get-vmnetadapter -vmname nanoserver1 | set-vmnetworkadapter -macaddressSpoofing on