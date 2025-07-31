# Launch Outlook COM Object
$outlook = New-Object -ComObject Outlook.Application
$namespace = $outlook.GetNamespace("MAPI")

# Log on to the "Recovery" profile (interactive window may appear if not already open)
$namespace.Logon("Recovery", $null, $false, $true)

# Get Deleted Items (3) and Inbox (6) for that profile
$deleted = $namespace.GetDefaultFolder(3)  # Deleted Items
$inbox = $namespace.GetDefaultFolder(6)    # Inbox

# Create/find target subfolder in Inbox
try {
    $targetFolder = $inbox.Folders.Item("Recovered Items")
} catch {
    $targetFolder = $inbox.Folders.Add("Recovered Items")
}

# Loop through Deleted Items in reverse
for ($i = $deleted.Items.Count; $i -gt 0; $i--) {
    try {
        $item = $deleted.Items.Item($i)

        if ($item.MessageClass -eq "IPM.Note") {
            $item.Move($targetFolder) | Out-Null
        } else {
            Write-Host "Skipped non-mail item #${i} of type $($item.MessageClass)"
        }

        # Release memory to avoid MAPI limits
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($item) | Out-Null
        Remove-Variable item
    } catch {
        Write-Host "Error moving item #${i}: $_"
    }
}

Write-Host "Done! All mail items from 'Recovery' profile moved from Deleted Items to Recovered Items."
