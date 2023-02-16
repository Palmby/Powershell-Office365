#Email Variables 
$username = #email_username
$password = #email_password
$secure = ConvertTo-SecureString -string $password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $secure 
$subject = "Notice of Email Forwarding"
$subject2 = "Notice of Email Access"
#
$ExchangeConnection = @{

   
    AppID = ""
    Organization = ""
    CertificateThumbprint = ''
}


#$AzureAD unattended Access
$connection = @{

    ApplicationID = ''
    TenantID = ''
    CertificateThumbprint = ''
}



Connect-AzureAD @connection 
#pull list of users that are disabled and are still licensed
$users = get-azureaduser -all $true | where {$_.accountenabled -eq $false -and  $_.AssignedLicenses -ne $null}


connect-exchangeonline @ExchangeConnection
$u = $users.userprincipalname 
foreach ($us in $u)

{
    $mailbox = Get-Mailbox -identity $us 
#pulls if there is a forwarding smtp address
if (!([string]::IsNullOrEmpty($mailbox.ForwardingsmtpAddress))) 

{
    $forwardingsmtpaddress = $mailbox.ForwardingsmtpAddress -replace ".*:"
    $body = "Hello $forwardingsmtpaddress, `nYou are currently having $us emails forwarding to you. `nif you do not need this anymore, please email ...`n`nThank you`nIT " 
    send-mailmessage -To "$forwardingsmtpaddress" -from "$username" -Subject $subject -Body $body -BodyAsHtml -SmtpServer smtp.office365.com -usessl -Credential $cred -Port 587

}

else {}

}
#pulls if there is a mailbox access
foreach ($uz in $u){
    $mailboxpermissons = get-mailboxpermission -identity $uz | Where-Object {($_.User -ne "NT AUTHORITY\SELF") -and ($_.IsInherited -ne $true) -and ($_.AccessRights -eq "FullAccess")}


if (!([string]::IsNullOrEmpty($mailboxpermissons.User)))
{
    $forwarding = $mailboxpermissons.User
    foreach ($for in $forwarding )
    {
    $body = "Hello $for, `n You currently have access to $uz emails. `n if you do not need this anymore, please email support@callmc.com `n `n Thank you `nIT " 
    send-mailmessage -To "$for" -from "$username" -Subject $subject2 -Body $body -BodyAsHtml -SmtpServer smtp.office365.com -usessl -Credential $cred -Port 587
    

    
}
}

else{}
}




