$Azureconnection = @{

            ApplicationID = ''
            TenantID = ''
            CertificateThumbprint = ''
}





Connect-azuread @Azureconnection 


$users = get-azureaduser -all $true | where {$_.accountenabled -eq $false} | select *

foreach ($user in $users)
{
    $objectID = $user.ObjectID
    $groups = Get-AzureADuserMember -ObjectId "$objectID"


    foreach ($u in $user)
    {
        $prop =  @{

            'User' = $u
            'Groups' = $groups -join ',' 
            'AssignedLicense' = $u.AssignedLicense

            }


            $obj = new-Object -TypeName PSObject -Property $prop
            $obj | Select-Object User, group |sort-object User | export-csv C:\temp\MCA_disabledusers.csv -NoTypeInformation -Append -Force

    }


}
