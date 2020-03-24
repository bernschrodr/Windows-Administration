$computerName = "s2"
Rename-Computer -NewName $computerName
Restart-Computer -Wait
#Настройка параметров адаптера
New-NetIPAddress -IPAddress 10.0.0.2 -InterfaceAlias "Ethernet" -DefaultGateway 10.10.10.10 -AddressFamily IPv4 -PrefixLength 8
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 10.10.10.10
#Отключение ipv6
Disable-NetAdapterBinding -Name "Ethernet" -ComponentID ms_tcpip6
#Установка DHCP роли для сервера
Install-WindowsFeature DHCP -IncludeManagementTools
netsh dhcp add securitygroups
Restart-Service dhcpserver
Set-DhcpServerv4DnsSetting -ComputerName $computerName -DynamicUpdates "Always" -DeleteDnsRRonLeaseExpiry $True
