$ErrorActionPreference = "Stop"

Function authenticate() {
    Disable-AzContextAutosave -Scope Process | Out-Null

    try {
        $AzureContext = (Connect-AzAccount -Identity).context
    }
    catch {
        Write-Output "There is no system-assigned user identity. Aborting.";
        exit
    }

    $AzureContext = Set-AzContext -SubscriptionName $AzureContext.Subscription -DefaultProfile $AzureContext
}

Function snapshot([Microsoft.Azure.Commands.Compute.Models.PSVirtualMachineList]$vm, [hashtable]$resource_tags) {
    $disk = $vm.StorageProfile.OsDisk
    $snapshot_name = "$($vm.Name)-$($disk.Name)-snap"
    $snap_config = New-AzSnapshotConfig -SourceUri $disk.ManagedDisk.Id -Location $vm.Location -CreateOption copy -Tag $resource_tags -Incremental
    try {
        Get-AzSnapshot -ResourceGroupName $vm.ResourceGroupName -SnapshotName $snapshot_name -ErrorVariable lookupError -ErrorAction SilentlyContinue | Out-Null
        if($lookupError.Count -eq 0) {
            Update-AzSnapshot -Snapshot $snap_config -SnapshotName $snapshot_name -ResourceGroupName $vm.ResourceGroupName | Out-Null
            Write-Output "Successfully refreshed snapshot $($snapshot_name)"
        } else {
            New-AzSnapshot -Snapshot $snap_config -SnapshotName $snapshot_name -ResourceGroupName $vm.ResourceGroupName | Out-Null
            Write-Output "Successfully created snapshot $($snapshot_name)"
        }

    }
    catch {
        Write-Error "failed to snapshot $($snapshot_name): $($Error[0])"
    }
}

function convert_resource_tags_to_hashtable([String]$resource_tags) {
    $table = @{}
    (ConvertFrom-Json $resource_tags).psobject.properties | Foreach-Object {
        $table.Add($_.Name, $_.Value)
    }
    $table.Add("Created", (Get-Date).ToLongDateString())
    return $table
}

Function main() {
    authenticate

    $tag_var = Get-AutomationVariable -Name 'TAG'
    $locations_var = Get-AutomationVariable -Name 'LOCATIONS'
    $resource_tags_var = Get-AutomationVariable -Name 'RESOURCE_TAGS'

    $tag_key, $tag_val = $tag_var.Split(":")
    $resource_tags = convert_resource_tags_to_hashtable -resource_tags $resource_tags_var
    $locations = $locations_var.Replace("`"","").Split(",")

    foreach($location in $locations) {
        Write-Output "Fetching Linux VMs in $($location)"
        $vms = Get-AzVM -Location $location | Where-Object {
            $_.StorageProfile.OsDisk.OsType -eq 'Linux' -and 
            $_.Tags.Keys -contains $tag_key -and 
            $_.Tags[$tag_key] -eq $tag_val
        }
        
        for ($i=0; $i -lt $vms.Length; $i++) {
            $vm = $vms[$i]
            Write-Output "[$($i+1)/$($vms.Length)] Snapshotting $($vm.Name) - $($vm.StorageProfile.OsDisk.Name)"
            snapshot -vm $vm -resource_tags $resource_tags
        }
    }
}

main
