# Check for Admin
If (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Host "Not running as administrator. Restarting with elevated privileges..."
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "Running with Administrator privileges..."

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

$actionList = @("Archive","Delete","Permanently Delete")

# Function: Show a numeric menu and return a valid selection
function Get-MenuSelection {
    param(
        [Parameter(Mandatory=$true)]
        [string[]]$Options
    )

    while ($true) {
        Write-Host "Please select an option by number:`n"
        
        for ($i = 0; $i -lt $Options.Count; $i++) {
            Write-Host "[$($i+1)] $($Options[$i])"
        }

        $selection = Read-Host "Enter your choice (1-$($Options.Count))"

        if ([int]::TryParse($selection, [ref]$null)) {
            $selection = [int]$selection
            if ($selection -ge 1 -and $selection -le $Options.Count) {
                return $Options[$selection-1]
            }
        }

        Write-Host "Invalid input. Please enter a number between 1 and $($Options.Count)."
    }
}

$action = Get-MenuSelection -Options $actionList

$looper = $true
while ($looper) {
        $days = Read-Host "Enter age limit for retention"
        if ([int]::TryParse($days, [ref]$null)) {
            $looper = $false
        }
    }



# Check if retention tag exists, create if missing
$tagName = "$action After $days Days"
if (-not (Get-RetentionPolicyTag -ErrorAction SilentlyContinue | Where-Object {$_.Name -eq $tagName})) {
    Write-Host "Creating retention tag '$tagName'..."
    if ($action -eq "Archive")
    {
        New-RetentionPolicyTag -Name $tagName `
            -Type All `
            -AgeLimitForRetention $days `
            -RetentionAction MoveToArchive `
            -RetentionEnabled $true
    }
    if ($action -eq "Delete")
    {
        New-RetentionPolicyTag -Name $tagName `
            -Type All `
            -AgeLimitForRetention $days `
            -RetentionAction DeleteAndAllowRecovery `
            -RetentionEnabled $true
    }
    if ($action -eq "Permanently Delete")
    {
        New-RetentionPolicyTag -Name $tagName `
            -Type All `
            -AgeLimitForRetention $days `
            -RetentionAction PermanentlyDelete `
            -RetentionEnabled $true
    }
}

# Check if retention policy exists, create if missing
$policyName = "$days Days $action Policy"
if (-not (Get-RetentionPolicy -ErrorAction SilentlyContinue | Where-Object {$_.Name -eq $policyName})) {
    Write-Host "Creating retention policy '$policyName'..."
    New-RetentionPolicy -Name $policyName -RetentionPolicyTagLinks $tagName
}
pause