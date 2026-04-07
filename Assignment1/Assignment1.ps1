# Assignment1.ps1

$subscription_id = "f884461c-434c-4223-84b3-bc90b2906100"
$resourceGroupName = "Assignment1-RG"
$location = "eastus"

Set-AzContext -SubscriptionId $subscription_id

# Check if resource group exists
$rg = Get-AzResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue

if (-not $rg) {
    Write-Host "Creating resource group: $resourceGroupName"
    New-AzResourceGroup `
        -Name $resourceGroupName `
        -Location $location
}
else {
    Write-Host "Resource group already exists: $resourceGroupName"
}

# Create unique storage account name
$randomSuffix = Get-Random -Maximum 99999
$storageAccountName = "assign1temp$randomSuffix"

Write-Host "Creating temporary storage account: $storageAccountName"

New-AzStorageAccount `
    -ResourceGroupName $resourceGroupName `
    -Name $storageAccountName `
    -Location $location `
    -SkuName Standard_LRS `
    -Kind StorageV2

Write-Host "Listing resources in subscription: $subscription_id"
Get-AzResource | Select-Object Name, ResourceGroupName, ResourceType, Location

Write-Host "Deleting temporary storage account: $storageAccountName"

Remove-AzStorageAccount `
    -ResourceGroupName $resourceGroupName `
    -Name $storageAccountName `
    -Force
