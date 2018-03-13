# Resource Group Where VM gets created. This group gets deleted once vhd is saved
RESOURCE_GROUP="DataScienceVM"

# Resource Group where VM vhd is saved, and available for download
VHD_RESOURCE_GROUP="DataScienceVM-VHD"

LOCATION="Southeast Asia"

STORAGEACCOUNT_NAME="dsvm$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 18 | head -n 1)"
VM_NAME="datascience-vm"
VM_SIZE="Standard_D4s_v3"
VM_IMAGE="microsoft-ads:linux-data-science-vm-ubuntu:linuxdsvmubuntu:1.1.7"

# Create VM Resource Group
az group create \
    --name $RESOURCE_GROUP \
    --location "$LOCATION"

# Create VHD storage Resource Group
az group create \
    --name $VHD_RESOURCE_GROUP \
    --location "$LOCATION"

# Create Storage Account
az storage account create \
    --name $STORAGEACCOUNT_NAME \
    --resource-group $VHD_RESOURCE_GROUP \
    --sku Standard_GRS \
    --encryption-services blob \
    --https-only true \
    --kind BlobStorage \
    --access-tier Hot

# Create Data Science VM
az vm create \
    --name $VM_NAME \
    --resource-group $RESOURCE_GROUP \
    --location "$LOCATION" \
    --image $VM_IMAGE \
    --size $VM_SIZE \
    --admin-username "datauser" \
    --generate-ssh-keys

# Deallocate and generalise Data Science VM
az vm deallocate --name $VM_NAME --resource-group $RESOURCE_GROUP
az vm generalize --name $VM_NAME --resource-group $RESOURCE_GROUP

# get disk name

# grant access to get sas url
az disk grant-access --duration-in-seconds 24000 --name datascience-vm_OsDisk_1_0ad61d757db34cdfa500c8b66194d1b5 --resource-group $RESOURCE_GROUP

# download 

# delete rg