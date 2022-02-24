# Azure file share

Network-attachable hard drive for data storage. The idea is to have a large drive
that you can easily mount either to local computers or cloud virtual machines.

Performance probably not as good as a local SSD, but should still be pretty fast.

You can use this drive with other services like Azure Batch or Container Instances

## Usage
```
terraform init
# !!! Replace [scott] with your workspace name !!!
terraform workspace new scott
terraform apply
```

A successful apply should report the following:
```
azurerm_storage_share.fileshare-data: Creation complete after 1s [id=https://grizzly6zua.file.core.windows.net/grizzly]

Apply complete! Resources: 6 added, 0 changed, 0 destroyed.
```

Note that the name of the storage account is randomly generated, in the example above it is `grizzly6zua`


## Mount on local computer

You can mount this drive on another computer using the `smb://` protocol with the following syntax: `smb://<storage-account-name>:<storage-account-key>@<storage-account-name>.file.core.windows.net/<share-name>`

1. On a Mac: Finder -> Go -> Connect to Server -> `smb://grizzly6zua.file.core.windows.net/grizzly`
    Name: STORAGE_ACCOUNT
    Password: STORAGE_ACCOUNT_KEY

2. Mac Terminal:
```
export STORAGE_ACCOUNT_KEY=`az storage account keys list --account-name grizzly6zua --query "[0].value" | tr -d '"'`
export STORAGE_ACCOUNT="grizzly6zua"
export SHARE_NAME="grizzly"
open "smb://${STORAGE_ACCOUNT}:${STORAGE_ACCOUNT_KEY}@${STORAGE_ACCOUNT}.file.core.windows.net/${SHARE_NAME}"
```

3. Linux terminal

There is a `mount_smb.sh` script in this subfolder. NOTE that you need 'sudo' permissions to mount the drive
```
export STORAGE_ACCOUNT_KEY=`az storage account keys list --account-name grizzly6zua --query "[0].value" | tr -d '"'`
export STORAGE_ACCOUNT="grizzly6zua"
export SHARE_NAME="grizzly"
./mount_azure_smb.sh
```

4. To unmount the drive:
```
umount /mnt/grizzly
```

## References

* https://docs.microsoft.com/en-us/azure/storage/files/storage-how-to-use-files-mac
* https://docs.microsoft.com/en-us/azure/container-instances/container-instances-volume-azure-files