#Map Sharepoint Site to Users OneDrive

#This is just a template. Follow the instructions in regards on how to prefill the Variables



$WebURL = ""
$WebID = ""
$SiteName = ""
$SiteID = ""
$ListID = ""

$reggrab = get-itemproperty HKCU:\SOFTWARE\Microsoft\OneDrive\Accounts\Business1 -Name UserEmail 

$userEmail =  $reggrab.userEmail

$odopen = "odopen://sync/?siteId=" + $SiteID + "&webId=" + $WebID + "&webUrl=" + $webURL + $SiteName + "&listId=" + $ListID + "&userEmail=" + $userEmail+ "&webTitle=" + $SiteName + ""

start-process $odopen