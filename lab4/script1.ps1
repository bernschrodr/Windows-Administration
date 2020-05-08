Import-Module ActiveDirectory

$obj=[ADSI]"LDAP://RootDSE"
$Domain = $obj.defaultNamingContext | Out-String
echo $domain
$createdUsers = @()
$createdGroups = @()
$createdContainers = @()

function createFromCsv {
  param ($csvPath)

  if ((Test-Path -Path $csvPath) -eq $false) {
    Write-Error -Category InvalidArgument "Wrong csv path"
    return
  }


  $csv = Import-Csv $csvPath 
  foreach ($user in $csv) {

    $userName = $user.Login
    $department = $user.Department
    $email = $user.Email
    $phone = $user.Phone
    $post = $user.Post
    $container = $user.Container
    $password = $user.Password
    $profilePath = $user.ProfilePath
    $homePath = $user.HomeDirectory
    $groups = $user.Groups -split " "

    #Парсим ФИО
    $fio = $user.fio -split " "
    $lastName = $fio[0]
    $firstName = $fio[1]
    $initials = $fio[2]

    # Создаем группы,которых нет
    $groups | ForEach-Object -Process {
      if ($null -eq (Get-ADGroup -Filter { Name -Like $_ })) {
        New-ADGroup -Name $_ -SamAccountName $_ -GroupCategory Security -GroupScope Global -DisplayName $_ 
      } }

    if(!(Get-ADObject -Filter 'DistinguishedName -eq $container')){
        if($container.contains("CN=")){
          $pos = $container.indexof('CN=')
          $cont = $container.subString($pos, $container.length - $pos)
          $pos = $container.IndexOf(',')
          $cont = $cont.subString(3)
        
        echo $cont
        New-ADObject -Name $cont  -Type "container" -Path $domain
        $createdContainers += $cont
    }}

    $container += ',' + $domain

    Try {
      New-ADUser -Name $user.FIO `
        -GivenName $firstName `
        -Surname $lastName `
        -SamAccountName  $userName `
        -Initials $initials `
        -Department $department `
        -EmailAddress $email `
        -OfficePhone $phone `
        -Title $post `
        -Path $container `
        -AccountPassword (ConvertTo-SecureString $password -AsPlainText -force) -Enabled $true `
        -ProfilePath $profilePath `
        -HomeDirectory $homePath -HomeDrive "X:" `
        -ErrorAction Stop

      $groups | ForEach-Object {
        Add-ADGroupMember -Identity $_ -Members $userName
      }
      $createdUsers += "$firstName $lastName"

      if((Test-Path -Path $homePath)){
        $path = "C:\AllUsers\$username"
        New-Item -Path $path -ItemType Directory
        New-SMBShare -Name $userName -Path $path -FullAccess "lab4.com\$username"
        $acl = Get-Acl $path
        $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($userName,"FullControl","Allow")
        $acl.SetAccessRule($accessRule)
        $acl | Set-Acl $path
      }

      $result = @()
      $result += ("Created Containers: " + $createdContainers.length)
      $result += $createdContainers
      $result += ("Created Users: " + $createdUsers.length)
      $result += $createdUsers
      $result += ("Created Groups: " + $createdGroups.length)
      $result += $createdGroups
      
      $result | ConvertTo-Html -Property @{l='Table'; e={$_}} | out-file created.html

    }
    Catch [Microsoft.ActiveDirectory.Management.ADIdentityAlreadyExistsException] {
      Write-Error -Message "User already exist"
      continue
    }
    
  }  
}

$filePath = "./data.csv" #Read-Host -Promt "Enter the path to csv"
createFromCsv($filePath)