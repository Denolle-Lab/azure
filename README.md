# Infrastructure-as-code on Azure

This repository contains [Terraform](https://www.terraform.io) code, to easily
create and remove Cloud resources on Microsoft Azure:

| subfolder | description |
| - | - |
| [basic_virtual_machine](basic_virtual_machine) | Virtual machine with Ubuntu 20.04 |
| [azure_file_share_data](azure_file_share_data) | Network attachable drive (mountable via smb://) |
| [aci_plus_volume](aci_plus_volume) | JupyterLab Docker Container via Azure Container Instance with azure_file_share_data home directory |
| [virtual_machine_gpu](virtual_machine_gpu) | GPU Virtual Machine with NVIDIA Drivers + conda preinstalled |

The lab group has an Azure "Subscription" managed via Azure Education. Terraform will create Cloud resources which cost money! Lab members are given permission to create resources by connecting a `uw.edu` email address as a subscription [Access Control "Contributor"](https://docs.microsoft.com/en-us/azure/role-based-access-control/rbac-and-directory-admin-roles). 

## Setup

We'll use `conda` to create an environment that includes command line utilities
to execute code in this repository. In particular, we need `terraform` and the
[Azure Command Line Interface (CLI)](https://docs.microsoft.com/en-us/cli/azure/)

```
conda env create
conda activate azure
```

Authenticate to Azure via a Microsoft account (`uw.edu` email) connected to our
Azure "Subscription"
```
az login
```

Check current login credentials:
```
az account show
```

## Organization

Each subfolder contains a stand-alone logical group of Cloud resources. To create the infrastructure,
navigate to a subfolder in the terminal and follow the README.md instructions.

### Workspaces
Each subfolder contains a recipe for a group of cloud resources with a self-describing subfolder name (`basic_virtual_machine`). Let's say several lab members each need a virtual machine. The recipe is the same and each time we use it, we create a new [Terraform Workspace](https://www.terraform.io/language/state/workspaces) to keep track of the Cloud resources created and not interfere with one another. For example:

```
cd basic_virtual_machine

# Connect to state backend (see 'Initial Setup' section below)
terraform init

terraform workspace new scott-incubator2022

# Optionally edit terraform.tfvars to change things like region or machine type
terraform apply

# Easily remove any costly Cloud resources
terraform destroy
terraform workspace delete scott-incubator2022
```

#### Active workspaces
⚠️ Everyone with sufficient Azure priviledges can see, modify, and delete terraform-managed resources:
```
terraform workspace list
terraform select scottGPU
terraform state list

# We can look at details (e.g. names, IP addresses, etc) of specific resources from `terraform state list`,
# for example azurerm_storage_account.fileshare-data:
terraform state show azurerm_storage_account.fileshare-data
```

#### Workspace state
Each workspace tracks its own Azure resources, but all this state is stored in a single `tfstate` file that is specified for each resource configuration in `main.tf`. That state file is stored in an Azure Blob Storage container so that it can be accessed from any machine - see [Initial Setup section below](#initial-setup).

```hcl
  backend "azurerm" {
    resource_group_name  = "tfstate"
    storage_account_name = "tfstate5063"
    container_name       = "tfstate"
    key                  = "linux-vm.tfstate"
  }
```

## Initial Setup

NOTE: this only needs doing once! We did it in Feb 2022 and are just leaving notes here for future reference

Terraform keeps track of Cloud resources in "state" files, which are stored in
in a "storage account container" (equivalent to AWS "S3 bucket"). It is first
necessary to create this storage account container, as all other pieces of infrastructure
are tracked there. We've documented this setup in the [backend folder](./backend)

NOTE: `.tfstate` files are created separately for each collection of infrastructure,
under the [STORAGE_ACCOUNT]/[CONTAINER]/[KEY], for example for our basic_virtual_machine
the configuration is tracked in `az://tfstate5063/tfstate/linux-vm.tfstate`

## Add new users to Azure Subscription 

> https://portal.azure.com --> 2. Subscriptions (Microsoft Azure Sponsorship)  --> 3. Access Control (IAM) --> Role Assignments --> Add --> Add Role Assignment (Contributor) --> +Select Members --> Add email address --> Review + Assign


## References

https://docs.microsoft.com/en-us/azure/developer/terraform/authenticate-to-azure?tabs=bash
