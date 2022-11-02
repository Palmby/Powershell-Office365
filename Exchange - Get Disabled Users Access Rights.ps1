#SCript pulls two reports
#Report A = pulls all disabled users and sees if they are licensed
#Report B = pulls all licensed users and says if their mailbox is monitored

#Exchange Unattended Access 

$ExchangeConnection = @{

    CertificateFilePath = "" 
    CertificatePassword = $(ConvertTo-SecureString -String "" -AsPlainText -Force)
    AppID = ""
    Organization = ""
}


#$AzureAD unattended Access
$connection = @{

    ApplicationID = ''
    TenantID = ''
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
    $obj | Select-Object User, groups, AssignedLicense |sort-object User | export-csv C:\temp\usersdisabled.csv  -NoTypeInformation -Append -Force

}


}


#part 2


Connect-ExchangeOnline @ExchangeConnection
$imported = Import-Csv C:\temp\mcausersdisabled.csv | where-object {$_.AssignedLicense -eq 'y'} 
$imports = $imported.User
foreach ($i in $imports)

{

    $permissions = get-mailboxpermission -identity $i | Where-Object {($_.User -ne "NT AUTHORITY\SELF") -and ($_.IsInherited -ne $true)} | select Identity, User, AccessRights -ErrorAction SilentlyContinue
    $forwarding = Get-Mailbox -identity $i | select identity, Forwardingsmtpaddress, DelivertoMailboxandForward 
    foreach ($ue in $user){
    $Property = @{

        'Username' = $forwarding.identity -join ','
        'User With Mailbox Access' = $permissions.user -join ','
        'AccessRights' = $permissions.AccessRights -join ','
        'ForwardingsmtpAddress' = $forwarding.Forwardingsmtpaddress
        'DelivertoMailbox&Forward' = $forwarding.DelivertoMailboxandForward

    }
    
    
    $o = new-Object -TypeName PSObject -Property $Property -ErrorAction SilentlyContinue   
        write-output $o |where-object {$o.Username -ne $null}| export-csv C:\temp\disabledusersforwarding.csv -NoTypeInformation -Append -Force -ErrorAction SilentlyContinue
}
    }
