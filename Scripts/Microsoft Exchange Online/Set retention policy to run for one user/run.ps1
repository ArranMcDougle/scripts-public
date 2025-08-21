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

# Get all retention policies
$policies = Get-RetentionPolicy

# List policies with numbers
Write-Host "Retention Policies:"
for ($i = 0; $i -lt $policies.Count; $i++) {
    Write-Host "$($i+1): $($policies[$i].Name)"
}

# Prompt user to select by number
$selection = Read-Host "Enter the number of the policy to assign"
if (($selection -as [int]) -and $selection -ge 1 -and $selection -le $policies.Count) {
    $selectedPolicy = $policies[$selection-1].Name
    Write-Host "You selected: $selectedPolicy"
    $answer = read-host "Enable policy for user? (Y/N)"
    if ($answer.ToLower() -eq 'y') { 
    # Assign policy to mailbox"
    Set-Mailbox -Identity $UPN -RetentionPolicy $selectedPolicy
    } else {
    Write-Host "Policy application cancelled."
    } 
    
} else {
    Write-Host "Invalid selection."
}

# Check if applied
Get-Mailbox -Identity $UPN | Select-Object DisplayName,RetentionPolicy
pause

Write-Host "Disconnecting from Exchange Online..."
Disconnect-ExchangeOnline
Write-Host "Done. Press any key to exit."
$host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")