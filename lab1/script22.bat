

@echo off

set /p inputstr="Choose auto/manual: "

:switch-case-example

  :: Call and mask out invalid call targets
  goto :switch-case-N-%inputstr% 2>nul || (
    :: Default case
    echo Something else
  )
  goto :switch-case-end
  
  :switch-case-N-manual
    netsh interface ip set address name="Ethernet" static 192.168.1.10 255.255.255.0 192.168.1.1
    netsh interface ipv4 set dns name="Ethernet" static  8.8.8.8 primary
    echo "ip set"
    goto :switch-case-end     

  :switch-case-N-auto
    netsh interface ipv4 set address name="Ethernet" source=dhcp
    netsh interface ipv4 set dns name="Ethernet" source=dhcp
    echo "ip set"
    goto :switch-case-end

:switch-case-end
   echo end program

 
