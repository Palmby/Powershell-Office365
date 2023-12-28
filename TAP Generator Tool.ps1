#Creates a TAP access pass 

connect-mggraph -scope UserAuthenticationMethod.ReadWrite.All
#Ask info to user


$Username = Read-host "Whats the Users Email?"
$OneTime = Read-Host "One Time Use? (Yes or NO)?"





if ($OneTime -eq 'Yes'){
    $Once = $True
}

elseif ($OneTime -eq 'No')
{
    $Once = $False 
}

else
{
    Write-output 'Input incorrect, closing'
    exit 
}

$prop = @{}
$prop.isUsableOnce = $Once
$prop.startDateTime = Get-Date -Format "yyyy-mm-dd hh:mm:ss"
$propjson = $prop | ConvertTo-Json 

$tap = New-MgUserAuthenticationTemporaryAccessPassMethod -UserID "$Username" -BodyParameter $propjson 
$tap

$password = $tap.TemporaryAccessPass

$TTL = $tap.LifetimeInMinutes

write-output "$Username TAP is set"
write-output "Password is $password" 
write-output "set for $TTL" 
write-output "Please copy the Temporary Access Pass"
pause
