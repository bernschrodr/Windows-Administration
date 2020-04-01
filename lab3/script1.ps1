Get-Disk | ft -AutoSize
$diskNumber = read-host "Enter disk number: "
$answer = read-host "All data will be erased, do you agree(y/n): "
switch ($answer) {
    'y' {
        Set-Disk -Number $diskNumber -IsOffline $false
        Set-Disk -Number $diskNumber -IsReadOnly $false
        Clear-Disk -Number $diskNumber -RemoveData -Confirm:$false
        Initialize-Disk -Number $diskNumber -PartitionStyle MBR
        New-Partition -DiskNumber $diskNumber -Size 1gb -DriveLetter L | Format-Volume -FileSystem NTFS -Confirm:$false
        Repair-Volume -DriveLetter L
        Get-Volume -DriveLetter L}
    'n' {
        Exit}
    Default { Write-Output 'Wrong input' }
}