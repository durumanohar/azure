# Authenticate to Azure
Connect-AzAccount

# Set your Azure subscription and resource group names
$subscriptionName = "YourSubscriptionName"
$resourceGroupName = "YourResourceGroupName"

# Set the Azure region where you want to create the resources
$location = "YourRegion"

# Set the image builder parameters
$imageBuilderTemplateName = "MyImageBuilderTemplate"
$imageName = "MyImage"
$sourceResourceId = "/subscriptions/$subscriptionName/resourceGroups/$resourceGroupName/providers/Microsoft.Compute/images/MySourceImage"
$imageOutputName = "MyImageOutput"
$imageOutputVersion = "1.0.0"

# Create a resource group
New-AzResourceGroup -Name $resourceGroupName -Location $location

# Create a VM image builder template
$imageBuilderTemplate = New-AzImageTemplateConfig -Location $location -OsState Generalized -OsType Linux `
    -Source $sourceResourceId -Customize -CustomizerScript "echo 'Hello, World!' > /tmp/helloworld.txt"

# Create the VM image builder
$imageBuilder = New-AzImageBuilder -ResourceGroupName $resourceGroupName -ImageBuilderTemplateName $imageBuilderTemplateName `
    -ImageTemplate $imageBuilderTemplate -Verbose

# Wait for the VM image builder to finish
$buildStatus = $imageBuilder | Get-AzImageBuilderRunOutput -OutputName "runOutput"
while ($buildStatus.Status -ne "Succeeded" -and $buildStatus.Status -ne "Failed") {
    $buildStatus = $imageBuilder | Get-AzImageBuilderRunOutput -OutputName "runOutput"
    Start-Sleep -Seconds 10
}

# Check if the VM image builder succeeded
if ($buildStatus.Status -eq "Succeeded") {
    # Create an image version from the VM image builder output
    $imageVersion = New-AzImageVersionConfig -Location $location -Source $imageBuilder.Id `
        -ImageVersion $imageOutputVersion -TargetRegion $location -TargetRegionType "Regional"

    # Create the final VM image from the image version
    New-AzImage -ResourceGroupName $resourceGroupName -GalleryName $imageName -GalleryImageVersion $imageVersion `
        -GalleryImageName $imageOutputName -Verbose

    Write-Host "Azure VM image builder image created successfully."
} else {
    Write-Host "Azure VM image builder failed to create the image."
}
