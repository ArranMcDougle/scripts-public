# check for Admin
If (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Install ExOM
Install-Module -Name ExchangeOnlineManagement

#bypass script run policy
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

# Import ExchangeOnlineManagement module
Import-Module ExchangeOnlineManagement

# Connect to Exchange Online
Connect-ExchangeOnline # Login
$UPN = Read-Host "Enter email address of user" # get email address of customer

try{
    #Enable auto-expanding archive
    Enable-Mailbox -Identity $UPN -AutoExpandingArchive

    #Test if enabled
    Get-Mailbox $UPN | FL AutoExpandingArchiveEnabled
}
catch{
    Write-Host "Failed to enable auto-expanding archive: $_" -ForegroundColor Red
}

#Disconnect
Disconnect-ExchangeOnline
pause