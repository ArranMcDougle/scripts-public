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

# Ensure the archive mailbox is enabled
$mbx = Get-Mailbox -Identity $UPN
if ($mbx.ArchiveStatus -ne "Active") {
    Write-Host "Enabling archive mailbox for $UPN..."
    Enable-Mailbox -Identity $UPN -Archive
}
# Enable Managed Folder Assistant
Write-Host "Starting Managed Folder Assistant"
Start-ManagedFolderAssistant -Identity $UPN

Write-Host "Disconnecting from Exchange Online..."
Disconnect-ExchangeOnline
Write-Host "Done. Press any key to exit."
$host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")