#Exchange Unattended Access 

$ExchangeConnection = @{

    CertificateFilePath = "" 
    CertificatePassword = $(ConvertTo-SecureString -String "" -AsPlainText -Force)
    AppID = ""
    Organization = ""
}


#$AzureAD unattended Access
$connection = @{

    TenantID = ''
    ApplicationID = ''
    CertificateThumbprint = ''
}

#Get list of disabled Users
Connect-azuread @connection


$users = get-azureaduser -all $true | where {$_.accountenabled -eq $false}  

foreach ($user in $users)
{
$objectID = $user.ObjectID
$license = $user.AssignedLicenses -join ','
$groups = Get-AzureADUserMembership -ObjectId "$objectID" | select Mail
$mail = $groups.Mail
$user.Mail
if ([string]::IsNullOrEmpty($license))
{
$islicensed = 'n'
}

else
{
$islicensed = 'y'
}


foreach ($u in $user)
{
$prop =  @{

    'User' = $u.Mail
    'Groups' = $mail -join ',' 
    'AssignedLicense' = $islicensed

    }


    $obj = new-Object -TypeName PSObject -Property $prop
    

}

}
Connect-ExchangeOnline @ExchangeConnection
$emails = $obj| Select-Object User
 


foreach ($email in $emails)

{

    $permissions = get-mailboxpermission -identity $email.User | select Identity, User, AccessRights | export-csv C:\temp\emails.csv -NoTypeInformation -Append -Force
    $forwarding = Get-mailboxpermission -identity $email.user | select identity, Forwardingsmtpaddress, DelivertoMailboxandForward 

    $obj2 = new-object -Type PSObject -Property @{

        'Username' = $permissions.identity
        'User With Mailbox Access' = $permissions.user
        'AccessRights' = $permissions.AccessRights
        'ForwardingsmtpAddress' = $forwarding.Forwardingsmtpaddress
        'DelivertoMailbox&Forward' = $forwarding.DelivertoMailboxandForward

        
    }
        $obj2 | select * | export-csv C:\temp\disabledusers.csv -NoTypeInformation
}
