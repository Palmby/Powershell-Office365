
#parse email list and upload to distribution group

#email list wil look like bob jones <bobjones@email.com>;

#upload email list to a txt file
$emails = (get-content #<file path ># ).Split(';')
$emailList = [System.Collections.Generic.List[string]]::new()



$regex = "[a-z0-9!#\$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#\$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?"



foreach ($email in $emails){
    $email -match $regex | out-null 
    $emaillist.add($matches.values)
    



}



#connect to exchange online and add the members here 

connect-exchangeonline 




foreach ($e in $emaillist)
{
    add-distributiongroupmember -identity #<identity of distro group"..." #> -member "$e"
}

