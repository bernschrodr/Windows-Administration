#Читаем Конфиг
$configFile = Get-Content "config.json" | ConvertFrom-Json

#Запускаем с другой машины находящейся в сети с s1 и s2
Invoke-Command -ComputerName "s2" -ScriptBlock { setup_s2 }
Invoke-Command -ComputerName "s1" -ScriptBlock { setup_s1 }

function setup_s2($config) {
  Rename-Computer -NewName $config.name
  Restart-Computer -Wait
  
  #Настройка параметров адаптера
  New-NetIPAddress -IPAddress $config.local_ip -InterfaceAlias $config.interface_name -DefaultGateway $config.gateway -AddressFamily IPv4 -PrefixLength $config.mask_length
  Set-DnsClientServerAddress -InterfaceAlias $config.interface_name -ServerAddresses $config.dns
  
  #Отключение ipv6
  Disable-NetAdapterBinding -Name $config.interface_name -ComponentID ms_tcpip6
  
  #Установка DHCP роли для сервера
  Install-WindowsFeature DHCP -IncludeManagementTools
  netsh dhcp add securitygroups
  Restart-Service dhcpserver
  Set-DhcpServerv4DnsSetting -ComputerName $config.name -DynamicUpdates "Always" -DeleteDnsRRonLeaseExpiry $True

}

function setup_s1 {
  #Начало для обоих серверов одинаковое, поэтому запускаем настройку с параметрами для s1
  setup_s2($configFile.server1)
  $config = $configFile.server1

  #Настройка области
  Add-DhcpServerv4Scope -name $config.scope.name -StartRange $config.scope.start_range -EndRange $config.scope.end_range -SubnetMask $config.scope.mask -State Active
  Add-DhcpServerv4ExclusionRange -ScopeID $config.scope.id -StartRange $config.scope.start_range -EndRange $config.scope.end_range
  Set-DhcpServerv4OptionValue -Value $config.local_ip -ScopeID $config.scope.id -ComputerName $config.name
  Set-DhcpServerv4OptionValue  -DnsDomain $config.scope.domain -ComputerName $config.name -DnsServer $config.scope.dns

  #Добавление Резервации
  Add-DhcpServerv4Reservation -ScopeId $config.scope.id -IPAddress $config.scope.reservation[0].ip -ClientId $config.scope.reservation[0].mac -Description $config.scope.reservation[0].description

  #Добавление политики
  Add-DhcpServerv4Policy -Name $config.policy[0].name -ScopeId $config.scope.id -Condition OR -MacAddress EQ, $config.policy.macMask

  #Настройка отработки отказа
  Add-DhcpServerv4Failover -ComputerName $config.name -Name $config.failover.name -PartnerServer $configFile.server2.name -ServerRole Standby -ScopeId $config.scope.id -ReservePercent $config.failover.reserve_percent -MaxClientLeadTime $config.failover.lead_time -AutoStateTransition $True -StateSwitchInterval $config.failover.switch_interval -SharedSecret $config.failover.secret
}