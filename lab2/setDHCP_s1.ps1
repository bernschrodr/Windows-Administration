$computerName = "s1"
Rename-Computer -NewName $computerName
Restart-Computer -Wait

#Настройка параметров адаптера
New-NetIPAddress -IPAddress 10.0.0.1 -InterfaceAlias "Ethernet" -DefaultGateway 10.10.10.10 -AddressFamily IPv4 -PrefixLength 8
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses 10.10.10.10

#Отключение ipv6
Disable-NetAdapterBinding -Name "Ethernet" -ComponentID ms_tcpip6

#Установка DHCP роли для сервера
Install-WindowsFeature DHCP -IncludeManagementTools
netsh dhcp add securitygroups
Restart-Service dhcpserver
Set-DhcpServerv4DnsSetting -ComputerName $computerName  -DynamicUpdates "Always" -DeleteDnsRRonLeaseExpiry $True

#Настройка области
Add-DhcpServerv4Scope -name "lab2Scope" -StartRange 10.0.0.100 -EndRange 10.0.0.200 -SubnetMask 255.0.0.0 -State Active    
Add-DhcpServerv4ExclusionRange -ScopeID 10.0.0.100 -StartRange 10.0.0.195 -EndRange 10.0.0.200
Set-DhcpServerv4OptionValue -OptionID 3 -Value 10.0.0.1 -ScopeID 10.0.0.100 -ComputerName $computerName
Set-DhcpServerv4OptionValue  -DnsDomain "SVD.loc" -ComputerName $computerName -DnsServer 10.10.10.10

#Добавление Резервации
Add-DhcpServerv4Reservation -ScopeId 10.0.0.100 -IPAddress 10.0.0.199 -ClientId "00-01-02-03-04-05" -Description "Reservation for lab2"

#Добавление политики
Add-DhcpServerv4Policy -Name "lab2" -MacAddress EQ, AA0102*

#Настройка отработки отказа
Add-DhcpServerv4Failover -ComputerName $computerName -Name "lab3-Failover" -PartnerServer "10.0.0.2" -ServerRole Standby -ScopeId 10.10.10.100 -ReservePercent 35 -MaxClientLeadTime 00:30:00 -AutoStateTransition $True -StateSwitchInterval 00:01:00 -SharedSecret "123"