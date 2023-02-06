# Azure Blob storage

Setup blob object storage for accessing datasets via `az://`

AWS: "S3 bucket"
Azure: "Storage container"


NOTE: not using an Azure Blob for terraform state, just storing locally on scott's computer for eScience incubator 2023

## Create

Need to first edit `terraform.tfvars`

```
terraform init
terraform apply
```

## Use

Step 1) Create temporary access token (full permissions)
```
# NOTE: 7 day max on these tokens
#end=`date -u -d "7 days" '+%Y-%m-%dT%H:%MZ'`

az storage container generate-sas \
    --account-name snowmelt\
    --name snowmelt \
    --permissions acdlrw \
    --expiry 2023-02-03T02:45Z \
    --auth-mode login \
    --as-user
```

Read-only token (note changed permissions to just 'rl')
https://learn.microsoft.com/en-us/cli/azure/storage/container?view=azure-cli-latest#az-storage-container-generate-sas
```
az storage container generate-sas \
    --account-name snowmelt\
    --name snowmelt \
    --permissions rl \
    --expiry 2023-02-13T19:15Z \
    --auth-mode login \
    --as-user
```

Step 2) Move files around
```
export export AZURE_STORAGE_SAS_TOKEN="se=2023-02-09T20...."
az storage blob list -c snowmelt --account-name snowmelt --output table

az storage blob upload \
    --account-name snowmelt \
    --container-name snowmelt \
    --name hello2.txt \
    --file /tmp/hello.txt \
    --output table

az storage blob download \
    --account-name snowmelt \
    --container-name snowmelt \
    --name hello.txt \
    --file /tmp/hello.txt \
    --output table

# Recursive copies
https://learn.microsoft.com/en-us/cli/azure/storage/blob?view=azure-cli-latest#az-storage-blob-sync

# This may or may not be useful...
# Append sas token for azcopy commands
azcopy copy hello.txt "https://snowmelt.blob.core.windows.net/snowmelt/?se=2023-02-03T02..."
```

## Remove!
```
terraform destroy
```


## References

https://learn.microsoft.com/en-us/azure/storage/blobs/storage-quickstart-blobs-cli

https://planetarycomputer.microsoft.com/docs/quickstarts/storage/

https://learn.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-v10

https://learn.microsoft.com/en-us/cli/azure/storage/container?view=azure-cli-latest#az-storage-container-generate-sas

https://github.com/hashicorp/terraform-provider-azurerm/tree/main/examples/storage/storage-container
