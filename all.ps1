step 1 -- create a VM image builder gallery
step 2 --create a deployment -- go thru portal to create --image templates --VM image version will send it to shared image gallery
build same region as the image, select managed identity 
customize run scripts and then this creates a vm 
build image VM identity

# For more information, see:
# https://learn.microsoft.com/en-us/azure/virtual-machines/image-builder-overview?WT.mc_id=AZ-MVP-5004159

# Register Features
Get-AzResourceProvider -ProviderNamespace Microsoft.Compute, Microsoft.KeyVault, Microsoft.Storage, Microsoft.VirtualMachineImages, Microsoft.Network, Microsoft.ManagedIdentity |
  Where-Object RegistrationState -ne Registered |
    Register-AzResourceProvider

# Create Managed Identity and Role

# Destination image resource group name
$imageResourceGroup = 'test_rg12023'

# Azure region
$location = 'EASTUS'

# Get the subscription ID, be sure to log into the correct subscription with Connect-AzAccount
# Your Azure Subscription ID
$subscriptionID = (Get-AzContext).Subscription.Id
Write-Output $subscriptionID

# Create the resource group for the managed identity and deployments
New-AzResourceGroup -Name $imageResourceGroup -Location $location

# Create a unique identity name based on the time
[int]$timeInt = $(Get-Date -UFormat '%s')
$imageRoleDefName = "Azure Image Builder Image Def $timeInt"
$identityName = "myIdentity$timeInt"
Write-Output $identityName
# make a note of the identity Name

# Create the User Identity and store the identity as variables for the next step
New-AzUserAssignedIdentity -ResourceGroupName $imageResourceGroup -Name $identityName -Location $location
$identityNameResourceId = (Get-AzUserAssignedIdentity -ResourceGroupName $imageResourceGroup -Name $identityName).Id
$identityNamePrincipalId = (Get-AzUserAssignedIdentity -ResourceGroupName $imageResourceGroup -Name $identityName).PrincipalId

# Download the JSON role definition template
$myRoleImageCreationUrl = 'https://raw.githubusercontent.com/azure/azvmimagebuilder/master/solutions/12_Creating_AIB_Security_Roles/aibRoleImageCreation.json'
$myRoleImageCreationPath = "myRoleImageCreation.json"
Invoke-WebRequest -Uri $myRoleImageCreationUrl -OutFile $myRoleImageCreationPath -UseBasicParsing

# Update the role definition template
# Do not update the next 5 lines
$Content = Get-Content -Path $myRoleImageCreationPath -Raw
$Content = $Content -replace '<subscriptionID>', $subscriptionID
$Content = $Content -replace '<rgName>', $imageResourceGroup
$Content = $Content -replace 'Azure Image Builder Service Image Creation Role', $imageRoleDefName
$Content | Out-File -FilePath $myRoleImageCreationPath -Force

# Create the new role definition -- gives user rights to do things in azure
New-AzRoleDefinition -InputFile $myRoleImageCreationPath

# Grant the role definition to the identity at the resource group scope
$RoleAssignParams = @{
  ObjectId = $identityNamePrincipalId
  RoleDefinitionName = $imageRoleDefName
  Scope = "/subscriptions/$subscriptionID/resourceGroups/$imageResourceGroup"
}
New-AzRoleAssignment @RoleAssignParams
# we not have an identity to run image builder to create images
#this is just needed onnce

# go to the portal and search for image templates , use same resource group created above 

########################################################################################
#STEP 2
# https://learn.microsoft.com/en-us/azure/virtual-machines/linux/image-builder-gallery
#
#
# https://learn.microsoft.com/en-us/azure/virtual-machines/image-version?tabs=portal%2Ccli2

########################################


# Code for image build

# Inline Command
New-Item -Type Directory -Path 'c:\\' -Name temp,
invoke-webrequest -uri 'https://aka.ms/downloadazcopy-v10-windows' -OutFile 'c:\\temp\\azcopy.zip',
Expand-Archive 'c:\\temp\\azcopy.zip' 'c:\\temp',
copy-item 'C:\\temp\\azcopy_windows_amd64_*\\azcopy.exe\\' -Destination 'c:\\temp'
