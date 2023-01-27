

$username = #"sendingemailaddress"
$password = #"emailpassword"
$secure = ConvertTo-SecureString -string $password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $secure 
$subject = #"Subject"
$body = #"EmailBody"
$attachment =#"attachment"

send-mailmessage -To "" -from "" -Subject $subject -Body $body -BodyAsHtml -Attachments $attachment -SmtpServer smtp.office365.com -usessl -Credential $cred -Port 587
<<<<<<< Updated upstream
=======


>>>>>>> Stashed changes
