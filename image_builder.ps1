# Authenticate to Azure
Connect-AzAccount

# Set your Azure subscription and resource group names
$subscriptionName = "YourSubscriptionName"
$resourceGroupName = "YourResourceGroupName"

# Set the Azure region where you want to create the resources
$location = "YourRegion"

# Set the shared image gallery details
$galleryName = "YourGalleryName"
$galleryImageDefinition = "YourImageDefinitionName"
$galleryVersion = "1.0.0"
$galleryImageVersion = "$galleryVersion-$(Get-Date -Format 'yyyyMMddHHmmss')"

# Set the source image details
$sourceImagePublisher = "Canonical"
$sourceImageOffer = "UbuntuServer"
$sourceImageSku = "18.04-LTS"
$sourceImageVersion = "latest"

# Create a resource group
New-AzResourceGroup -Name $resourceGroupName -Location $location -Verbose

# Create a managed image for the source image
$imageConfig = New-AzImageConfig -Location $location -SourceImageId "/subscriptions/$subscriptionName/resourceGroups/$resourceGroupName/providers/Microsoft.Compute/images/MySourceImage"
$image = New-AzImage -Image $imageConfig -ImageName "MyManagedImage" -ResourceGroupName $resourceGroupName -Verbose

# Create a VM image builder
$imageBuilderConfig = New-AzImageBuilderConfig -Image $imageConfig
$imageBuilder = New-AzImageBuilder -ImageBuilder $imageBuilderConfig -ResourceGroupName $resourceGroupName -ImageBuilderTemplateName "MyImageBuilderTemplate" -ImageName $galleryImageVersion -Verbose

# Create an Azure Shared Image Gallery
$galleryConfig = New-AzGalleryConfig -Location $location
New-AzGallery -GalleryName $galleryName -ResourceGroupName $resourceGroupName -Gallery $galleryConfig -Verbose

# Create an Azure Shared Image Gallery image definition
$imageDefinitionConfig = New-AzGalleryImageDefinitionConfig -Location $location -OsState Generalized -OsType Linux -Publisher $sourceImagePublisher -Offer $sourceImageOffer -Sku $sourceImageSku -Version $sourceImageVersion -ManagedImage $image.Id
New-AzGalleryImageDefinition -GalleryImageDefinitionName $galleryImageDefinition -ResourceGroupName $resourceGroupName -GalleryName $galleryName -GalleryImageDefinition $imageDefinitionConfig -Verbose

# Create a version for the Azure Shared Image Gallery image
$imageVersionConfig = New-AzGalleryImageVersionConfig -Location $location -ManagedImage $image.Id -ManagedImageVersion $image.Version -TargetRegion $location -TargetRegionType "Regional"
New-AzGalleryImageVersion -GalleryImageVersionName $galleryVersion -ResourceGroupName $resourceGroupName -GalleryName $galleryName -GalleryImageDefinitionName $galleryImageDefinition -GalleryImageVersion $imageVersionConfig -Verbose

# Publish the Azure Shared Image Gallery image version
Publish-AzGalleryImageVersion -GalleryImageVersionName $galleryVersion -ResourceGroupName $resourceGroupName -GalleryName $galleryName -GalleryImageDefinitionName $galleryImageDefinition -Verbose

Write-Host "Azure VM image builder and image published to the shared image gallery successfully."
