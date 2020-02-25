$inputstr = read-host "input auto/manual: "
switch ($inputstr) {
    "auto" {
        $NetAdapter = Get-NetAdapter -Name "Ethernet"
        $NetAdapter | Set-NetIPInterface -Dhcp Enabled
        $NetAdapter | Set-DnsClientServerAddress -ResetServerAddresses
    }
    "manual" {
        $NetAdapter = Get-NetAdapter -Name "Ethernet"
        $NetAdapter | New-NetIPAddress -IPAddress 192.168.1.10 -PrefixLength 24 -DefaultGateway 192.168.1.1 #prefixLength 24 это равно колличеству единиц в двоичной записи маски  = 255.255.255.0.
        $NetAdapter | Set-DnsClientServerAddress -ServerAddresses 8.8.8.8
    }
    Default { Write-Output "Wrong input" }
}