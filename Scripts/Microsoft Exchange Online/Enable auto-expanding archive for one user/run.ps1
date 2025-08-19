# Check for Admin
If (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Host "Not running as administrator. Restarting with elevated privileges..."
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "Running with Administrator privileges..."

$UPN = Read-Host "Enter email address of user"

# Install module if missing
if (-not (Get-Module -ListAvailable -Name ExchangeOnlineManagement)) {
    Write-Host "Installing ExchangeOnlineManagement module..."
    Install-Module -Name ExchangeOnlineManagement -Force -AllowClobber
}

Write-Host "Setting execution policy to Bypass..."
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

Write-Host "Importing ExchangeOnlineManagement module..."
Import-Module ExchangeOnlineManagement

Write-Host "Connecting to Exchange Online..."
Connect-ExchangeOnline

try {
    Write-Host "Enabling auto-expanding archive..."
    Enable-Mailbox -Identity $UPN -AutoExpandingArchive

    Write-Host "Verifying settings..."
    Get-Mailbox $UPN | FL AutoExpandingArchiveEnabled
}
catch {
    Write-Host "Failed to enable auto-expanding archive: $_" -ForegroundColor Red
}

Write-Host "Disconnecting from Exchange Online..."
Disconnect-ExchangeOnline

Write-Host "Done. Press any key to exit."
$host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")