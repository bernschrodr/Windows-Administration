$found = Get-ADObject -Filter {Name -like "unit-to-delete"}
$container = $found.DistinguishedName 
$Users = dsquery user "$container"
$Users | dsrm -noprompt