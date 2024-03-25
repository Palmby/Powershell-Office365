Connect-ExchangeOnline

$mailboxes = get-mailbox -ResultSize unlimited -RecipientTypeDetails sharedmailbox | select -expandproperty primarysmtpaddress



foreach ($mailbox in $mailboxes)
{
    $users = Get-MailboxPermission $mailbox  | where {$_.user -notlike "NT Authority\SELF" } | select -expandproperty user 
    $fullaccessusers = $users -join ', '
    


    $obj = [pscustomobject] @{

        MailboxName = "$mailbox"
        Users = "$fullaccessusers"

    }


    $obj | export-csv C:\temp\sharedmailboxaccess.csv -NoTypeInformation -Append
}

