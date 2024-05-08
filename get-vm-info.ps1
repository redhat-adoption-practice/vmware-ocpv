# Connect to the vCenter Server
$server = "your_vcenter_server"
$username = "your_username"
$password = "your_password"
Connect-VIServer -Server $server -User $username -Password $password

# Retrieve combined VM information
$vmInfo = Get-VM | ForEach-Object {
    $vm = $_
    $networks = (Get-NetworkAdapter -VM $vm | ForEach-Object { $_.NetworkName }) -join ', '
    $guestOS = $vm.Guest.OSFullName
    $storageUsedGB = [math]::Round($vm.UsedSpaceGB, 2)

    # Build the output object
    [PSCustomObject]@{
        Name = $vm.Name
        OS = if ($guestOS) { $guestOS } else { "Unknown" }
        Networks = if ($networks) { $networks } else { "No network assigned" }
        "Storage Used (GB)" = $storageUsedGB
    }
}

# Export the combined information to a CSV file
$vmInfo | Export-Csv -Path "vm_combined_info.csv" -NoTypeInformation

# Display the combined information in the console
$vmInfo | Format-Table -AutoSize

# Disconnect from the vCenter Server
Disconnect-VIServer -Server $server -Confirm:$false
