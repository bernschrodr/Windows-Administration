set /p inputstr="input string: "
net localgroup /ADD GPart2%inputstr%
net user UPart2%inputstr%  * /USERCOMMENT:"Create test user" /ADD
net localgroup GPart2%inputstr% UPart2%inputstr% /ADD
echo %inputstr%