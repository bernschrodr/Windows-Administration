$inputstr=read-host "input name: "
$inputstr -replace ' ', ''
$inputstr=$inputstr.Substring(0,4)
$Password=read-host "input password: " -AsSecureString
$user="UPart3"
$group="GPart3"

New-LocalGroup -Name $group$inputstr
New-LocalUser $user$inputstr -Password $Password
Add-LocalGroupMember -Group $group$inputstr -Member $user$inputstr
Enable-LocalUser $user$inputstr
