###############Grabs all users in a tenant and gets their mailbox size#####################

Connect-ExchangeOnline

get-mailbox | get-mailboxstatistics | ft displayname, totalitemsize | out-file C:\temp\mailboxsize.txt
#get-mailbox | get-mailboxstatistics | sort-object TotalItemSize -ascending | Select DisplayName, TotalitemSize
