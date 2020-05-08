$found = Get-ADObject -Filter {Name -like "Deleted Objects" }
$distinguishedName = $found.DistinguishedName
$deletedUsers = Get-ADObject -Filter {ObjectClass -eq "user"} -IncludeDeletedObjects
$deletedUsers | Restore-ADObject