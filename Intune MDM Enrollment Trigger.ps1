#pull Tenant information
$key = 'SYSTEM\CurrentControlSet\Control\CloudDomainJoin\TenantInfo\*'

$MDMEnrollmentURL = Get-itemproperty $path -Name MdmEnrollmentUrl
$MdmTermsOfUseUrl = Get-itemproperty $path -Name MdmTermsOfUseUrl
$MdMComplianceUrl = Get-itemproperty $path -Name MdmComplianceUrl
#checks if the Computer is joined to AAD
try
{
    $keyinfo = Get-Item "HKLM:\$key"
}
catch
{
    Write-Host "Tenant ID is not found! Check and ensure if the computer is joined to Azure Active Directory"
    exit 1001
}


$url = $keyinfo.name


$url = $url.Split("\")[-1]


$path = "HKLM:\SYSTEM\CurrentControlSet\Control\CloudDomainJoin\TenantInfo\$url"


if(!(Test-Path $path))
{
    Write-Host "KEY $path not found! Check if workstation is Azure Active Directory Joined"
    exit 1001
}

else{ }


#------------------------------------------------Check Registry if MDM Keys are present---------------------------------------------------
#Check for MdmEnrollmentURL

   

if ($MDMEnrollmentURL -eq $null)
{

    New-ItemProperty -LiteralPath $path -Name 'MdmEnrollmentUrl' -Value 'https://enrollment.manage.microsoft.com/enrollmentserver/discovery.svc' -PropertyType String -Force -ea SilentlyContinue
}


#Check for MdmTermsofUseURL

if ($MdmTermsOfUseUrl -eq $null)
{
    New-ItemProperty -LiteralPath $path -Name 'MdmTermsOfUseUrl' -Value 'https://portal.manage.microsoft.com/TermsofUse.aspx' -PropertyType String -Force -ea SilentlyContinue;
}
#Check for MdMComplianceURL




if ($MdMComplianceUrl -eq $null)
{
    New-ItemProperty -LiteralPath $path -Name 'MdmComplianceUrl' -Value 'https://portal.manage.microsoft.com/?portalAction=Compliance' -PropertyType String -Force -ea SilentlyContinue;
}

#---------------------------------------------------------------------------------------------------------------------------------------


#-------------------------------Trigger MDM API Call on Local Machine-------------------------------------------------------------------

try{
    C:\Windows\system32\deviceenroller.exe /c /AutoEnrollMDM
    Write-Host "Device is performing the MDM enrollment!"
   exit 0
}
catch{
    Write-Host "Something went wrong (C:\Windows\system32\deviceenroller.exe)"
   exit 1001          
}
