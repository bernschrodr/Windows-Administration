set /p inputstr="input string: "
set inputstr=%inputstr: =%
set inputstr=%inputstr:~0,4%
set group="GPart2"
set user="UPart2"
net localgroup /ADD %group%%inputstr%
net user %user%%inputstr%  * /USERCOMMENT:"Create test user" /ADD
net localgroup %group%%inputstr% %user%%inputstr% /ADD
net user %user%%inputstr% /active:yes
net user %user%%inputstr%