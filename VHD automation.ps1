# Define Variables
$ProfileShare = "\\PalmFS\profiles"
$User = "cbrown"  # Takes username as input argument
$VHDSize = 30GB  # Define default VHD size
$VHDType = "Dynamic"  # Dynamic or Fixed

# VHD Path
$VHDPath = "$ProfileShare\$User\Profile_user.vhdx"

# Check if the User Directory Exists
if (-not (Test-Path -Path "$ProfileShare\$User")) {
    New-Item -Path "$ProfileShare\$User" -ItemType Directory
}

# Create VHD File
if (-not (Test-Path -Path $VHDPath)) {
    New-VHD -Path $VHDPath -SizeBytes $VHDSize -Dynamic -Confirm:$false
    Write-Host "VHD for user $User created at $VHDPath"
} else {
    Write-Host "VHD already exists for user $User."
}