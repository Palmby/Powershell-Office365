#Create new file
new-item "C:\Scripts\Mobile Communications\Add_to_KnowBe4\knowbe4$((Get-Date).ToString('MM-dd-yyyy')).txt"
select-mgprofile 'beta'
[array]$exclusion = @()
<#
<#

#Azure Unattended Access
$azconnection = @{
    ApplicationID = 'c00d1161-234a-4d6d-b4c0-6580370e249b'
    TenantID = '15d3e2bf-8ed6-49f0-ab92-fe89364630ee'
    CertificateThumbprint = 'EAB0CED1040DB6A3DCDEA94AD618D0C8540325AA'
    
}

#>
#Exchange unattended Access
$Exconnection = @{
  AppID = "c00d1161-234a-4d6d-b4c0-6580370e249b"
  Organization = "callmc.onmicrosoft.com"
  CertificateThumbprint = 'EAB0CED1040DB6A3DCDEA94AD618D0C8540325AA'
  }
 
  
  $mgconnection = @{

    ClientID = 'c00d1161-234a-4d6d-b4c0-6580370e249b'
    TenantID = '15d3e2bf-8ed6-49f0-ab92-fe89364630ee'
    CertificateThumbprint = 'EAB0CED1040DB6A3DCDEA94AD618D0C8540325AA'

}



#connect-azuread #@azconnection
connect-mggraph @mgconnection
connect-exchangeonline @exconnection

#ADD SHARED MAILBOX TO EXCLUDED LIST
$shared =  get-mailbox -recipienttypedetails 'Sharedmailbox'
$sm = $shared.userprincipalname 

foreach ($s in $sm)
{
    $exclusion += $s 

}


#import CSV of excluded users 
$csv = import-csv "C:\Scripts\Mobile Communications\MCA_CSVs\knowbe4_exclusions.csv"
$principal = $csv.userprincipalname

foreach ($c in $principal)
{
    $exclusion += $c 
}




#GET ALL USERS NOT IN THE EXCLUSION GROUP
$us = Get-MgUser -all | where {$_.usertype -eq 'member' -and $exclusion -notcontains $_.Mail -and $_.AssignedLicenses -ne $null -and $_.AccountEnabled -eq $true} 


#GRAB KNOWBE4 SECURITY GROUP INFORMATION
$group = Get-MgGroup -all | where {$_.displayname -eq 'KnowBe4Members'}
$g = $group.ID 

#ADD USERS TO KNOWBE4 AND LOG IT
foreach ($u in $us)
{
    $display = $u.displayname
    $user = $u.ID
    $membership = Get-MgUserMemberOf -userID "$user"

    if ($membership.ID -notcontains "$g"){
        New-MGgroupmember -groupid "$g" -DirectoryObjectId "$user"
        Write-output "$display is being added to KnowBe4"
        add-content "C:\Scripts\Mobile Communications\Add_to_KnowBe4\knowbe4$((Get-Date).ToString('MM-dd-yyyy')).txt" "$display is being added to KnowBe4"



    }

    else{}
    



}
add-content "C:\Scripts\Mobile Communications\Add_to_KnowBe4\knowbe4$((Get-Date).ToString('MM-dd-yyyy')).txt" "---------------------------------------------------------------"


#REMOVE EXCLUDED USERS IF APART OF SECURITY GROUP

$excludeusers = Get-MgUser -all | where {$exclusion -contains $_.Mail }


foreach ($excludeduser in $excludeusers)

{
    $excludedisplay = $excludeduser.displayname
    $excludeuser = $excludeduser.ID
    $excludemembership = Get-MgUserMemberOf -userID "$excludeuser"


    if ($excludemembership.ID -contains "$g"){
        Remove-MgGroupMemberByRef -groupid "$g" -DirectoryObjectId "$excludeuser"
        Write-output "$excludedisplay is apart of the Exclude List and is in the security group, so it is being removed"
        add-content "C:\Scripts\Mobile Communications\Add_to_KnowBe4\knowbe4$((Get-Date).ToString('MM-dd-yyyy')).txt" "$excludedisplay is apart of the Exclude List and is in the security group, so it is being removed"



    }

    else{}
}

$username = "ITNotifications@callmc.com"
$password = "v2yiizB7lzT5y7LIhT7yXFU9SR0mWzzWpGaxtpISv6BZp6o7hD"
$secure = ConvertTo-SecureString -string $password -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $secure 
$subject = "MCA Users added to KnowBe4 $((Get-Date).ToString('MM-dd-yyyy'))"
$body = "Attached is the list"
$attachment ="C:\Scripts\Mobile Communications\Add_to_KnowBe4\knowbe4$((Get-Date).ToString('MM-dd-yyyy')).txt"

send-mailmessage -To "kpalmby@btpllc.net" -CC "BMiller@btpllc.net", "ASavatisensei@btpllc.net", "lmlong@btpllc.net" -from "ITNotifications@callmc.com" -Subject $subject -Body $body -BodyAsHtml -Attachments $attachment -SmtpServer smtp.office365.com -usessl -Credential $cred -Port 587
