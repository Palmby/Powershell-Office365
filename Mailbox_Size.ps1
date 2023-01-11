###############Grabs all users in a tenant and gets their mailbox size#####################

$connection = @{
AppID = ""
Organization = ".onmicrosoft.com"
CertificateThumbprint = ''
}

Connection-exchangeonline @connection
  
Get-Mailbox | Get-MailboxStatistics  | Select-Object DisplayName, totalitemsize, @{Name="TotalItemSizeMB"; Expression={[math]::Round(($_.TotalItemSize.ToString().Split("(")[1].Split(" ")[0].Replace(",","")/1MB),0)}} | sort-object  "TotalItemSizeMB" | export-csv   
