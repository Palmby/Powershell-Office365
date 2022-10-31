#Exchange Unattended Access 

$ExchangeConnection = @{

    CertificateFilePath = "" 
    CertificatePassword = $(ConvertTo-SecureString -String "" -AsPlainText -Force)
    AppID = ""
    Organization = ""
}

Connect-ExchangeOnline @ExchangeConnection
$emails = import-csv C:\temp\t.csv | select User



foreach ($email in $emails)

{

    get-mailboxpermission -identity $email.User | select Identity, User, AccessRights | export-csv C:\temp\emails.csv -NoTypeInformation -Append -Force

}