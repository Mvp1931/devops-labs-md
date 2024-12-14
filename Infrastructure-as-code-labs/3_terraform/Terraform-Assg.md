> [Go Home](../iac-labs.md)

# Objective:

## Familiarize students with Terraform installation and workspace setup. Deploy a simple resource using Terraform.

-   Install Terraform on your system (Windows/Linux/Mac).
-   Verify installation by checking the Terraform version.

---

-   Write a Terraform configuration file to create an Azure Virtual Machine.
-   Define the Resource Group and Region as Variables.
-   Apply the configuration using terraform apply.

---

## Terraform installation on windows

-   Download the latest version of Terraform from the official website.
-   Or run the following command in the PowerShell:

```powershell
choco install terraform
```

check the installation by running the following command in the PowerShell:

```powershell
pwsh $ terraform -version
Terraform v1.10.0
on windows_amd64
```

---

## Creating a Azure VM using Terraform

-   for this we need to create a terraform configuration file. and terraform variables file.
-   Create a file named `main.tf` in the same directory where you have the `variables.tf` file.

## Before you start, you need to login to Azure CLI

```powershell
pwsh $ az login
```

-   Enter the credentials of your Azure account.
-   Choose the subscription you want to use.
-   Choose the region you want to use.
-   Set up the **environment variables** for the Azure subscription.

## Create the terraform configuration file and variables file

```powershell
pwsh $ terraform init
```

This command will create a `.terraform` directory in the current directory and a `main.tf` file in it.

---

# Defining Terraform main and variables file

`main.tf` file

```tf

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "newVnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "newSubnet"
  address_prefixes     = ["10.0.1.0/24"]
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
}

# Network Security Group
resource "azurerm_network_security_group" "nsg" {
  name                = "newNetworkSecurityGroup"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Network Security Group Association
resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Public IP
resource "azurerm_public_ip" "public_ip" {
  name                = "newPublicIP"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"  # Changed from Dynamic to Static
  sku                 = "Standard"  # Added Standard SKU
}

# Network Interface
resource "azurerm_network_interface" "network_interface" {
  name                = "newNetworkInterface"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "newLinuxVM"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.network_interface.id]
  size                = "Standard_B2s"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"  # Ubuntu 22.04 LTS
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  computer_name                   = "newLinuxVM"
  admin_username                  = "azureuser"
  admin_password                  = var.admin_password
  disable_password_authentication = false
}
```

`Variables.tf` file

```tf
variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "Central India"
}

variable "admin_password" {
  description = "Administrator password for the VM"
  type        = string
  sensitive   = true  # Marks the password as sensitive to prevent accidental exposure
}
```

`output.tf` file that prints the public IP address of the VM

```tf
# Outputs (optional, but helpful)
output "public_ip_address" {
  value = azurerm_public_ip.public_ip.ip_address
}
```

## Create the VM

-   Run `terraform plan` to print the configuration that is about to be provisioned.

```powershell
pwsh $ terraform plan

var.admin_password
  Administrator password for the VM

  Enter a value:

var.resource_group_name
  Name of the resource group

  Enter a value: newTFResourceGroup


Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

 # azurerm_linux_virtual_machine.vm will be created
  + resource "azurerm_linux_virtual_machine" "vm" {
      + admin_password                                         = (sensitive value)
      + admin_username                                         = "azureuser"
      + allow_extension_operations                             = true
      + bypass_platform_safety_checks_on_user_schedule_enabled = false
      + computer_name                                          = "newLinuxVM"
      + disable_password_authentication                        = false
      + disk_controller_type                                   = (known after apply)
      + extensions_time_budget                                 = "PT1H30M"
      + id                                                     = (known after apply)
      + location                                               = "centralindia"
      + max_bid_price                                          = -1
      + name                                                   = "newLinuxVM"
      + network_interface_ids                                  = [
          + "/subscriptions/bec96e6b-8cfc-4a7b-87bf-bfaba37d28ad/resourceGroups/newTFResourceGroup/providers/Microsoft.Network/networkInterfaces/newNetworkInterface",
        ]
      + patch_assessment_mode                                  = "ImageDefault"
      + patch_mode                                             = "ImageDefault"
      + platform_fault_domain                                  = -1
      + priority                                               = "Regular"
      + private_ip_address                                     = (known after apply)
      + private_ip_addresses                                   = (known after apply)
      + provision_vm_agent                                     = true
      + public_ip_address                                      = (known after apply)
      + public_ip_addresses                                    = (known after apply)
      + resource_group_name                                    = "newTFResourceGroup"
      + size                                                   = "Standard_B2s"
      + virtual_machine_id                                     = (known after apply)
      + vm_agent_platform_updates_enabled                      = false

      + os_disk {
          + caching                   = "ReadWrite"
          + disk_size_gb              = (known after apply)
          + name                      = (known after apply)
          + storage_account_type      = "Standard_LRS"
          + write_accelerator_enabled = false
        }

      + source_image_reference {
          + offer     = "0001-com-ubuntu-server-jammy"
          + publisher = "Canonical"
          + sku       = "22_04-lts"
          + version   = "latest"
        }

      + termination_notification (known after apply)
    }

  # azurerm_network_interface.network_interface will be created
  + resource "azurerm_network_interface" "network_interface" {
      + applied_dns_servers         = (known after apply)
      + id                          = (known after apply)
      + internal_domain_name_suffix = (known after apply)
      + location                    = "centralindia"
      + mac_address                 = (known after apply)
      + name                        = "newNetworkInterface"
      + private_ip_address          = (known after apply)
      + private_ip_addresses        = (known after apply)
      + resource_group_name         = "newTFResourceGroup"
      + virtual_machine_id          = (known after apply)

      + ip_configuration {
          + gateway_load_balancer_frontend_ip_configuration_id = (known after apply)
          + name                                               = "internal"
          + primary                                            = (known after apply)
          + private_ip_address                                 = (known after apply)
          + private_ip_address_allocation                      = "Dynamic"
          + private_ip_address_version                         = "IPv4"
          + public_ip_address_id                               = (known after apply)
          + subnet_id                                          = (known after apply)
        }
    }

  # azurerm_network_security_group.nsg will be created
  + resource "azurerm_network_security_group" "nsg" {
      + id                  = (known after apply)
      + location            = "centralindia"
      + name                = "newNetworkSecurityGroup"
      + resource_group_name = "newTFResourceGroup"
      + security_rule       = [
          + {
              + access                                     = "Allow"
              + destination_address_prefix                 = "*"
              + destination_address_prefixes               = []
              + destination_application_security_group_ids = []
              + destination_port_range                     = "22"
              + destination_port_ranges                    = []
              + direction                                  = "Inbound"
              + name                                       = "SSH"
              + priority                                   = 1001
              + protocol                                   = "Tcp"
              + source_address_prefix                      = "*"
              + source_address_prefixes                    = []
              + source_application_security_group_ids      = []
              + source_port_range                          = "*"
              + source_port_ranges                         = []
                # (1 unchanged attribute hidden)
            },
        ]
    }

  # azurerm_public_ip.public_ip will be created
  + resource "azurerm_public_ip" "public_ip" {
      + allocation_method       = "Static"
      + ddos_protection_mode    = "VirtualNetworkInherited"
      + fqdn                    = (known after apply)
      + id                      = (known after apply)
      + idle_timeout_in_minutes = 4
      + ip_address              = (known after apply)
      + ip_version              = "IPv4"
      + location                = "centralindia"
      + name                    = "newPublicIP"
      + resource_group_name     = "newTFResourceGroup"
      + sku                     = "Standard"
      + sku_tier                = "Regional"
    }

  # azurerm_resource_group.rg will be created
  + resource "azurerm_resource_group" "rg" {
      + id       = (known after apply)
      + location = "centralindia"
      + name     = "newTFResourceGroup"
    }

  # azurerm_subnet.subnet will be created
  + resource "azurerm_subnet" "subnet" {
      + address_prefixes                              = [
          + "10.0.1.0/24",
        ]
      + default_outbound_access_enabled               = true
      + id                                            = (known after apply)
      + name                                          = "newSubnet"
      + private_endpoint_network_policies             = "Disabled"
      + private_link_service_network_policies_enabled = true
      + resource_group_name                           = "newTFResourceGroup"
      + virtual_network_name                          = "newVnet"
    }

  # azurerm_subnet_network_security_group_association.nsg_association will be created
  + resource "azurerm_subnet_network_security_group_association" "nsg_association" {
      + id                        = (known after apply)
      + network_security_group_id = (known after apply)
      + subnet_id                 = (known after apply)
    }

  # azurerm_virtual_network.vnet will be created
  + resource "azurerm_virtual_network" "vnet" {
      + address_space       = [
          + "10.0.0.0/16",
        ]
      + dns_servers         = (known after apply)
      + guid                = (known after apply)
      + id                  = (known after apply)
      + location            = "centralindia"
      + name                = "newVnet"
      + resource_group_name = "newTFResourceGroup"
      + subnet              = (known after apply)
    }

Plan: 8 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + public_ip_address = (known after apply)

─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.
```

-   Then you apply the configuration with `terraform apply` command

```powershell
...
...
...
Plan: 1 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

azurerm_linux_virtual_machine.vm: Creating...
azurerm_linux_virtual_machine.vm: Still creating... [10s elapsed]
azurerm_linux_virtual_machine.vm: Still creating... [20s elapsed]
azurerm_linux_virtual_machine.vm: Still creating... [30s elapsed]
azurerm_linux_virtual_machine.vm: Still creating... [40s elapsed]
azurerm_linux_virtual_machine.vm: Creation complete after 48s [id=/subscriptions/bec96e6b-8cfc-4a7b-87bf-bfaba37d28ad/resourceGroups/newTFResourceGroup/providers/Microsoft.Compute/virtualMachines/newLinuxVM]

Apply complete! Resources: 1 added, 0 changed, 0 destroyed.

Outputs:

public_ip_address = "52.172.194.118"
```

-   View the provisioned Configuration with `terraform show` command

```powershell
pwsh $ terraform show
# azurerm_linux_virtual_machine.vm:
resource "azurerm_linux_virtual_machine" "vm" {
    admin_password                                         = (sensitive value)
    admin_username                                         = "azureuser"
    allow_extension_operations                             = true
    availability_set_id                                    = null
    bypass_platform_safety_checks_on_user_schedule_enabled = false
    capacity_reservation_group_id                          = null
    computer_name                                          = "newLinuxVM"
    dedicated_host_group_id                                = null
    dedicated_host_id                                      = null
    disable_password_authentication                        = false
    disk_controller_type                                   = null
    edge_zone                                              = null
    encryption_at_host_enabled                             = false
    eviction_policy                                        = null
    extensions_time_budget                                 = "PT1H30M"
    id                                                     = "/subscriptions/bec96e6b-8cfc-4a7b-87bf-bfaba37d28ad/resourceGroups/newTFResourceGroup/providers/Microsoft.Compute/virtualMachines/newLinuxVM"
    license_type                                           = null
    location                                               = "centralindia"
    max_bid_price                                          = -1
    name                                                   = "newLinuxVM"
    network_interface_ids                                  = [
        "/subscriptions/bec96e6b-8cfc-4a7b-87bf-bfaba37d28ad/resourceGroups/newTFResourceGroup/providers/Microsoft.Network/networkInterfaces/newNetworkInterface",
    ]
    patch_assessment_mode                                  = "ImageDefault"
    patch_mode                                             = "ImageDefault"
    platform_fault_domain                                  = -1
    priority                                               = "Regular"
    private_ip_address                                     = "10.0.1.4"
    private_ip_addresses                                   = [
        "10.0.1.4",
    ]
    provision_vm_agent                                     = true
    proximity_placement_group_id                           = null
    public_ip_address                                      = "52.172.194.118"
    public_ip_addresses                                    = [
        "52.172.194.118",
    ]
    reboot_setting                                         = null
    resource_group_name                                    = "newTFResourceGroup"
    secure_boot_enabled                                    = false
    size                                                   = "Standard_B2s"
    source_image_id                                        = null
    user_data                                              = null
    virtual_machine_id                                     = "4002f161-b43f-407c-8d5e-66c4b4f41b2f"
    virtual_machine_scale_set_id                           = null
    vm_agent_platform_updates_enabled                      = false
    vtpm_enabled                                           = false
    zone                                                   = null

    os_disk {
        caching                          = "ReadWrite"
        disk_encryption_set_id           = null
        disk_size_gb                     = 30
        name                             = "newLinuxVM_OsDisk_1_a54368ef955f427a8a89f80d54d218bd"
        secure_vm_disk_encryption_set_id = null
        security_encryption_type         = null
        storage_account_type             = "Standard_LRS"
        write_accelerator_enabled        = false
    }

    source_image_reference {
        offer     = "0001-com-ubuntu-server-jammy"
        publisher = "Canonical"
        sku       = "22_04-lts"
        version   = "latest"
    }
}

# azurerm_network_interface.network_interface:
resource "azurerm_network_interface" "network_interface" {
    accelerated_networking_enabled = false
    applied_dns_servers            = []
    auxiliary_mode                 = null
    auxiliary_sku                  = null
    dns_servers                    = []
    edge_zone                      = null
    id                             = "/subscriptions/bec96e6b-8cfc-4a7b-87bf-bfaba37d28ad/resourceGroups/newTFResourceGroup/providers/Microsoft.Network/networkInterfaces/newNetworkInterface"
    internal_dns_name_label        = null
    internal_domain_name_suffix    = "sy0h3fzy4iquvnbbvxjcirjlxe.rx.internal.cloudapp.net"
    ip_forwarding_enabled          = false
    location                       = "centralindia"
    mac_address                    = null
    name                           = "newNetworkInterface"
    private_ip_address             = "10.0.1.4"
    private_ip_addresses           = [
        "10.0.1.4",
    ]
    resource_group_name            = "newTFResourceGroup"
    tags                           = {}
    virtual_machine_id             = null

    ip_configuration {
        gateway_load_balancer_frontend_ip_configuration_id = null
        name                                               = "internal"
        primary                                            = true
        private_ip_address                                 = "10.0.1.4"
        private_ip_address_allocation                      = "Dynamic"
        private_ip_address_version                         = "IPv4"
        public_ip_address_id                               = "/subscriptions/bec96e6b-8cfc-4a7b-87bf-bfaba37d28ad/resourceGroups/newTFResourceGroup/providers/Microsoft.Network/publicIPAddresses/newPublicIP"
        subnet_id                                          = "/subscriptions/bec96e6b-8cfc-4a7b-87bf-bfaba37d28ad/resourceGroups/newTFResourceGroup/providers/Microsoft.Network/virtualNetworks/newVnet/subnets/newSubnet"
    }
}

# azurerm_network_security_group.nsg:
resource "azurerm_network_security_group" "nsg" {
    id                  = "/subscriptions/bec96e6b-8cfc-4a7b-87bf-bfaba37d28ad/resourceGroups/newTFResourceGroup/providers/Microsoft.Network/networkSecurityGroups/newNetworkSecurityGroup"
    location            = "centralindia"
    name                = "newNetworkSecurityGroup"
    resource_group_name = "newTFResourceGroup"
    security_rule       = [
        {
            access                                     = "Allow"
            description                                = null
            destination_address_prefix                 = "*"
            destination_address_prefixes               = []
            destination_application_security_group_ids = []
            destination_port_range                     = "22"
            destination_port_ranges                    = []
            direction                                  = "Inbound"
            name                                       = "SSH"
            priority                                   = 1001
            protocol                                   = "Tcp"
            source_address_prefix                      = "*"
            source_address_prefixes                    = []
            source_application_security_group_ids      = []
            source_port_range                          = "*"
            source_port_ranges                         = []
        },
    ]
    tags                = {}
}

# azurerm_public_ip.public_ip:
resource "azurerm_public_ip" "public_ip" {
    allocation_method       = "Static"
    ddos_protection_mode    = "VirtualNetworkInherited"
    edge_zone               = null
    id                      = "/subscriptions/bec96e6b-8cfc-4a7b-87bf-bfaba37d28ad/resourceGroups/newTFResourceGroup/providers/Microsoft.Network/publicIPAddresses/newPublicIP"
    idle_timeout_in_minutes = 4
    ip_address              = "52.172.194.118"
    ip_tags                 = {}
    ip_version              = "IPv4"
    location                = "centralindia"
    name                    = "newPublicIP"
    resource_group_name     = "newTFResourceGroup"
    sku                     = "Standard"
    sku_tier                = "Regional"
    tags                    = {}
    zones                   = []
}

# azurerm_resource_group.rg:
resource "azurerm_resource_group" "rg" {
    id         = "/subscriptions/bec96e6b-8cfc-4a7b-87bf-bfaba37d28ad/resourceGroups/newTFResourceGroup"
    location   = "centralindia"
    managed_by = null
    name       = "newTFResourceGroup"
    tags       = {}
}

# azurerm_subnet.subnet:
resource "azurerm_subnet" "subnet" {
    address_prefixes                              = [
        "10.0.1.0/24",
    ]
    default_outbound_access_enabled               = true
    id                                            = "/subscriptions/bec96e6b-8cfc-4a7b-87bf-bfaba37d28ad/resourceGroups/newTFResourceGroup/providers/Microsoft.Network/virtualNetworks/newVnet/subnets/newSubnet"
    name                                          = "newSubnet"
    private_endpoint_network_policies             = "Disabled"
    private_link_service_network_policies_enabled = true
    resource_group_name                           = "newTFResourceGroup"
    service_endpoint_policy_ids                   = []
    service_endpoints                             = []
    virtual_network_name                          = "newVnet"
}

# azurerm_subnet_network_security_group_association.nsg_association:
resource "azurerm_subnet_network_security_group_association" "nsg_association" {
    id                        = "/subscriptions/bec96e6b-8cfc-4a7b-87bf-bfaba37d28ad/resourceGroups/newTFResourceGroup/providers/Microsoft.Network/virtualNetworks/newVnet/subnets/newSubnet"
    network_security_group_id = "/subscriptions/bec96e6b-8cfc-4a7b-87bf-bfaba37d28ad/resourceGroups/newTFResourceGroup/providers/Microsoft.Network/networkSecurityGroups/newNetworkSecurityGroup"
    subnet_id                 = "/subscriptions/bec96e6b-8cfc-4a7b-87bf-bfaba37d28ad/resourceGroups/newTFResourceGroup/providers/Microsoft.Network/virtualNetworks/newVnet/subnets/newSubnet"
}

# azurerm_virtual_network.vnet:
resource "azurerm_virtual_network" "vnet" {
    address_space           = [
        "10.0.0.0/16",
    ]
    bgp_community           = null
    dns_servers             = []
    edge_zone               = null
    flow_timeout_in_minutes = 0
    guid                    = "977e3496-f238-4a21-b421-add224452bbc"
    id                      = "/subscriptions/bec96e6b-8cfc-4a7b-87bf-bfaba37d28ad/resourceGroups/newTFResourceGroup/providers/Microsoft.Network/virtualNetworks/newVnet"
    location                = "centralindia"
    name                    = "newVnet"
    resource_group_name     = "newTFResourceGroup"
    subnet                  = [
        {
            address_prefixes                              = [
                "10.0.1.0/24",
            ]
            default_outbound_access_enabled               = true
            delegation                                    = []
            id                                            = "/subscriptions/bec96e6b-8cfc-4a7b-87bf-bfaba37d28ad/resourceGroups/newTFResourceGroup/providers/Microsoft.Network/virtualNetworks/newVnet/subnets/newSubnet"
            name                                          = "newSubnet"
            private_endpoint_network_policies             = "Disabled"
            private_link_service_network_policies_enabled = true
            route_table_id                                = null
            security_group                                = "/subscriptions/bec96e6b-8cfc-4a7b-87bf-bfaba37d28ad/resourceGroups/newTFResourceGroup/providers/Microsoft.Network/networkSecurityGroups/newNetworkSecurityGroup"
            service_endpoint_policy_ids                   = []
            service_endpoints                             = []
        },
    ]
    tags                    = {}
}


Outputs:

public_ip_address = "52.172.194.118"
```

now to test the vm's successful creation, SSH into the VM using the public IP address.

```bash
pwsh $ ssh azureuser@52.172.194.118
The authenticity of host '52.172.194.118 (52.172.194.118)' can't be established.
ED25519 key fingerprint is SHA256:eF7iHKzf/5cYchl2GTVxmujCB/Qr+cW0gg+D8AhAJ+M.
This key is not known by any other names.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '52.172.194.118' (ED25519) to the list of known hosts.
azureuser@52.172.194.118's password:
Welcome to Ubuntu 22.04.5 LTS (GNU/Linux 6.5.0-1025-azure x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Tue Dec  3 08:12:08 UTC 2024

  System load:  0.0               Processes:             117
  Usage of /:   5.2% of 28.89GB   Users logged in:       0
  Memory usage: 7%                IPv4 address for eth0: 10.0.1.4
  Swap usage:   0%

Expanded Security Maintenance for Applications is not enabled.

0 updates can be applied immediately.

Enable ESM Apps to receive additional future security updates.
See https://ubuntu.com/esm or run: sudo pro status


The list of available updates is more than a week old.
To check for new updates run: sudo apt update


The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

azureuser@newLinuxVM:~$ ls
azureuser@newLinuxVM:~$ pwd
/home/azureuser
azureuser@newLinuxVM:~$ cat /etc/os-release
PRETTY_NAME="Ubuntu 22.04.5 LTS"
NAME="Ubuntu"
VERSION_ID="22.04"
VERSION="22.04.5 LTS (Jammy Jellyfish)"
VERSION_CODENAME=jammy
ID=ubuntu
ID_LIKE=debian
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
UBUNTU_CODENAME=jammy
azureuser@newLinuxVM:~$ exit

logout
Connection to 52.172.194.118 closed.
```

-   Now, you can remove the provisioned configuration with `terraform destroy` command.

```powershell
pwsh $ terraform destroy
var.admin_password
  Administrator password for the VM

  Enter a value:

var.resource_group_name
  Name of the resource group

  Enter a value: newTFResourceGroup

azurerm_resource_group.rg: Refreshing state... [id=/subscriptions/bec96e6b-8cfc-4a7b-87bf-bfaba37d28ad/resourceGroups/newTFResourceGroup]
azurerm_public_ip.public_ip: Refreshing state... [id=/subscriptions/bec96e6b-8cfc-4a7b-87bf-bfaba37d28ad/resourceGroups/newTFResourceGroup/providers/Microsoft.Network/publicIPAddresses/newPublicIP]
azurerm_network_security_group.nsg: Refreshing state... [id=/subscriptions/bec96e6b-8cfc-4a7b-87bf-bfaba37d28ad/resourceGroups/newTFResourceGroup/providers/Microsoft.Network/networkSecurityGroups/newNetworkSecurityGroup]
azurerm_virtual_network.vnet: Refreshing state... [id=/subscriptions/bec96e6b-8cfc-4a7b-87bf-bfaba37d28ad/resourceGroups/newTFResourceGroup/providers/Microsoft.Network/virtualNetworks/newVnet]
azurerm_subnet.subnet: Refreshing state... [id=/subscriptions/bec96e6b-8cfc-4a7b-87bf-bfaba37d28ad/resourceGroups/newTFResourceGroup/providers/Microsoft.Network/virtualNetworks/newVnet/subnets/newSubnet]
azurerm_subnet_network_security_group_association.nsg_association: Refreshing state... [id=/subscriptions/bec96e6b-8cfc-4a7b-87bf-bfaba37d28ad/resourceGroups/newTFResourceGroup/providers/Microsoft.Network/virtualNetworks/newVnet/subnets/newSubnet]
azurerm_network_interface.network_interface: Refreshing state... [id=/subscriptions/bec96e6b-8cfc-4a7b-87bf-bfaba37d28ad/resourceGroups/newTFResourceGroup/providers/Microsoft.Network/networkInterfaces/newNetworkInterface]
azurerm_linux_virtual_machine.vm: Refreshing state... [id=/subscriptions/bec96e6b-8cfc-4a7b-87bf-bfaba37d28ad/resourceGroups/newTFResourceGroup/providers/Microsoft.Compute/virtualMachines/newLinuxVM]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  # azurerm_linux_virtual_machine.vm will be destroyed
  - resource "azurerm_linux_virtual_machine" "vm" {
      - admin_password                                         = (sensitive value) -> null
      - admin_username                                         = "azureuser" -> null
      - allow_extension_operations                             = true -> null
      - bypass_platform_safety_checks_on_user_schedule_enabled = false -> null
      - computer_name                                          = "newLinuxVM" -> null
      - disable_password_authentication                        = false -> null
      - encryption_at_host_enabled                             = false -> null
      - extensions_time_budget                                 = "PT1H30M" -> null
      - id                                                     = "/subscriptions/bec96e6b-8cfc-4a7b-87bf-bfaba37d28ad/resourceGroups/newTFResourceGroup/providers/Microsoft.Compute/virtualMachines/newLinuxVM" -> null
      - location                                               = "centralindia" -> null
      - max_bid_price                                          = -1 -> null
      - name                                                   = "newLinuxVM" -> null
      - network_interface_ids                                  = [
          - "/subscriptions/bec96e6b-8cfc-4a7b-87bf-bfaba37d28ad/resourceGroups/newTFResourceGroup/providers/Microsoft.Network/networkInterfaces/newNetworkInterface",
        ] -> null
      - patch_assessment_mode                                  = "ImageDefault" -> null
      - patch_mode                                             = "ImageDefault" -> null
      - platform_fault_domain                                  = -1 -> null
      - priority                                               = "Regular" -> null
      - private_ip_address                                     = "10.0.1.4" -> null
      - private_ip_addresses                                   = [
          - "10.0.1.4",
        ] -> null
      - provision_vm_agent                                     = true -> null
      - public_ip_address                                      = "52.172.194.118" -> null
      - public_ip_addresses                                    = [
          - "52.172.194.118",
        ] -> null
      - resource_group_name                                    = "newTFResourceGroup" -> null
      - secure_boot_enabled                                    = false -> null
      - size                                                   = "Standard_B2s" -> null
      - tags                                                   = {} -> null
      - virtual_machine_id                                     = "4002f161-b43f-407c-8d5e-66c4b4f41b2f" -> null
      - vm_agent_platform_updates_enabled                      = false -> null
      - vtpm_enabled                                           = false -> null
        # (14 unchanged attributes hidden)

      - os_disk {
          - caching                          = "ReadWrite" -> null
          - disk_size_gb                     = 30 -> null
          - name                             = "newLinuxVM_OsDisk_1_a54368ef955f427a8a89f80d54d218bd" -> null
          - storage_account_type             = "Standard_LRS" -> null
          - write_accelerator_enabled        = false -> null
            # (3 unchanged attributes hidden)
        }

      - source_image_reference {
          - offer     = "0001-com-ubuntu-server-jammy" -> null
          - publisher = "Canonical" -> null
          - sku       = "22_04-lts" -> null
          - version   = "latest" -> null
        }
    }

  # azurerm_network_interface.network_interface will be destroyed
  - resource "azurerm_network_interface" "network_interface" {
      - accelerated_networking_enabled = false -> null
      - applied_dns_servers            = [] -> null
      - dns_servers                    = [] -> null
      - id                             = "/subscriptions/bec96e6b-8cfc-4a7b-87bf-bfaba37d28ad/resourceGroups/newTFResourceGroup/providers/Microsoft.Network/networkInterfaces/newNetworkInterface" -> null
      - internal_domain_name_suffix    = "sy0h3fzy4iquvnbbvxjcirjlxe.rx.internal.cloudapp.net" -> null
      - ip_forwarding_enabled          = false -> null
      - location                       = "centralindia" -> null
      - mac_address                    = "60-45-BD-72-F9-EE" -> null
      - name                           = "newNetworkInterface" -> null
      - private_ip_address             = "10.0.1.4" -> null
      - private_ip_addresses           = [
          - "10.0.1.4",
        ] -> null
      - resource_group_name            = "newTFResourceGroup" -> null
      - tags                           = {} -> null
      - virtual_machine_id             = "/subscriptions/bec96e6b-8cfc-4a7b-87bf-bfaba37d28ad/resourceGroups/newTFResourceGroup/providers/Microsoft.Compute/virtualMachines/newLinuxVM" -> null
        # (4 unchanged attributes hidden)

      - ip_configuration {
          - name                                               = "internal" -> null
          - primary                                            = true -> null
          - private_ip_address                                 = "10.0.1.4" -> null
          - private_ip_address_allocation                      = "Dynamic" -> null
          - private_ip_address_version                         = "IPv4" -> null
          - public_ip_address_id                               = "/subscriptions/bec96e6b-8cfc-4a7b-87bf-bfaba37d28ad/resourceGroups/newTFResourceGroup/providers/Microsoft.Network/publicIPAddresses/newPublicIP" -> null
          - subnet_id                                          = "/subscriptions/bec96e6b-8cfc-4a7b-87bf-bfaba37d28ad/resourceGroups/newTFResourceGroup/providers/Microsoft.Network/virtualNetworks/newVnet/subnets/newSubnet" -> null
            # (1 unchanged attribute hidden)
        }
    }

  # azurerm_network_security_group.nsg will be destroyed
  - resource "azurerm_network_security_group" "nsg" {
      - id                  = "/subscriptions/bec96e6b-8cfc-4a7b-87bf-bfaba37d28ad/resourceGroups/newTFResourceGroup/providers/Microsoft.Network/networkSecurityGroups/newNetworkSecurityGroup" -> null
      - location            = "centralindia" -> null
      - name                = "newNetworkSecurityGroup" -> null
      - resource_group_name = "newTFResourceGroup" -> null
      - security_rule       = [
          - {
              - access                                     = "Allow"
              - destination_address_prefix                 = "*"
              - destination_address_prefixes               = []
              - destination_application_security_group_ids = []
              - destination_port_range                     = "22"
              - destination_port_ranges                    = []
              - direction                                  = "Inbound"
              - name                                       = "SSH"
              - priority                                   = 1001
              - protocol                                   = "Tcp"
              - source_address_prefix                      = "*"
              - source_address_prefixes                    = []
              - source_application_security_group_ids      = []
              - source_port_range                          = "*"
              - source_port_ranges                         = []
                # (1 unchanged attribute hidden)
            },
        ] -> null
      - tags                = {} -> null
    }

  # azurerm_public_ip.public_ip will be destroyed
  - resource "azurerm_public_ip" "public_ip" {
      - allocation_method       = "Static" -> null
      - ddos_protection_mode    = "VirtualNetworkInherited" -> null
      - id                      = "/subscriptions/bec96e6b-8cfc-4a7b-87bf-bfaba37d28ad/resourceGroups/newTFResourceGroup/providers/Microsoft.Network/publicIPAddresses/newPublicIP" -> null
      - idle_timeout_in_minutes = 4 -> null
      - ip_address              = "52.172.194.118" -> null
      - ip_tags                 = {} -> null
      - ip_version              = "IPv4" -> null
      - location                = "centralindia" -> null
      - name                    = "newPublicIP" -> null
      - resource_group_name     = "newTFResourceGroup" -> null
      - sku                     = "Standard" -> null
      - sku_tier                = "Regional" -> null
      - tags                    = {} -> null
      - zones                   = [] -> null
        # (1 unchanged attribute hidden)
    }

  # azurerm_resource_group.rg will be destroyed
  - resource "azurerm_resource_group" "rg" {
      - id         = "/subscriptions/bec96e6b-8cfc-4a7b-87bf-bfaba37d28ad/resourceGroups/newTFResourceGroup" -> null
      - location   = "centralindia" -> null
      - name       = "newTFResourceGroup" -> null
      - tags       = {} -> null
        # (1 unchanged attribute hidden)
    }

  # azurerm_subnet.subnet will be destroyed
  - resource "azurerm_subnet" "subnet" {
      - address_prefixes                              = [
          - "10.0.1.0/24",
        ] -> null
      - default_outbound_access_enabled               = true -> null
      - id                                            = "/subscriptions/bec96e6b-8cfc-4a7b-87bf-bfaba37d28ad/resourceGroups/newTFResourceGroup/providers/Microsoft.Network/virtualNetworks/newVnet/subnets/newSubnet" -> null
      - name                                          = "newSubnet" -> null
      - private_endpoint_network_policies             = "Disabled" -> null
      - private_link_service_network_policies_enabled = true -> null
      - resource_group_name                           = "newTFResourceGroup" -> null
      - service_endpoint_policy_ids                   = [] -> null
      - service_endpoints                             = [] -> null
      - virtual_network_name                          = "newVnet" -> null
    }

  # azurerm_subnet_network_security_group_association.nsg_association will be destroyed
  - resource "azurerm_subnet_network_security_group_association" "nsg_association" {
      - id                        = "/subscriptions/bec96e6b-8cfc-4a7b-87bf-bfaba37d28ad/resourceGroups/newTFResourceGroup/providers/Microsoft.Network/virtualNetworks/newVnet/subnets/newSubnet" -> null
      - network_security_group_id = "/subscriptions/bec96e6b-8cfc-4a7b-87bf-bfaba37d28ad/resourceGroups/newTFResourceGroup/providers/Microsoft.Network/networkSecurityGroups/newNetworkSecurityGroup" -> null
      - subnet_id                 = "/subscriptions/bec96e6b-8cfc-4a7b-87bf-bfaba37d28ad/resourceGroups/newTFResourceGroup/providers/Microsoft.Network/virtualNetworks/newVnet/subnets/newSubnet" -> null
    }

  # azurerm_virtual_network.vnet will be destroyed
  - resource "azurerm_virtual_network" "vnet" {
      - address_space           = [
          - "10.0.0.0/16",
        ] -> null
      - dns_servers             = [] -> null
      - flow_timeout_in_minutes = 0 -> null
      - guid                    = "977e3496-f238-4a21-b421-add224452bbc" -> null
      - id                      = "/subscriptions/bec96e6b-8cfc-4a7b-87bf-bfaba37d28ad/resourceGroups/newTFResourceGroup/providers/Microsoft.Network/virtualNetworks/newVnet" -> null
      - location                = "centralindia" -> null
      - name                    = "newVnet" -> null
      - resource_group_name     = "newTFResourceGroup" -> null
      - subnet                  = [
          - {
              - address_prefixes                              = [
                  - "10.0.1.0/24",
                ]
              - default_outbound_access_enabled               = true
              - delegation                                    = []
              - id                                            = "/subscriptions/bec96e6b-8cfc-4a7b-87bf-bfaba37d28ad/resourceGroups/newTFResourceGroup/providers/Microsoft.Network/virtualNetworks/newVnet/subnets/newSubnet"
              - name                                          = "newSubnet"
              - private_endpoint_network_policies             = "Disabled"
              - private_link_service_network_policies_enabled = true
              - security_group                                = "/subscriptions/bec96e6b-8cfc-4a7b-87bf-bfaba37d28ad/resourceGroups/newTFResourceGroup/providers/Microsoft.Network/networkSecurityGroups/newNetworkSecurityGroup"
              - service_endpoint_policy_ids                   = []
              - service_endpoints                             = []
                # (1 unchanged attribute hidden)
            },
        ] -> null
      - tags                    = {} -> null
        # (2 unchanged attributes hidden)
    }

Plan: 0 to add, 0 to change, 8 to destroy.

Changes to Outputs:
  - public_ip_address = "52.172.194.118" -> null

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

azurerm_subnet_network_security_group_association.nsg_association: Destroying... [id=/subscriptions/bec96e6b-8cfc-4a7b-87bf-bfaba37d28ad/resourceGroups/newTFResourceGroup/providers/Microsoft.Network/virtualNetworks/newVnet/subnets/newSubnet]
azurerm_linux_virtual_machine.vm: Destroying... [id=/subscriptions/bec96e6b-8cfc-4a7b-87bf-bfaba37d28ad/resourceGroups/newTFResourceGroup/providers/Microsoft.Compute/virtualMachines/newLinuxVM]
azurerm_subnet_network_security_group_association.nsg_association: Destruction complete after 4s
azurerm_network_security_group.nsg: Destroying... [id=/subscriptions/bec96e6b-8cfc-4a7b-87bf-bfaba37d28ad/resourceGroups/newTFResourceGroup/providers/Microsoft.Network/networkSecurityGroups/newNetworkSecurityGroup]
azurerm_linux_virtual_machine.vm: Still destroying... [id=/subscriptions/bec96e6b-8cfc-4a7b-87bf-...oft.Compute/virtualMachines/newLinuxVM, 10s elapsed]
azurerm_network_security_group.nsg: Still destroying... [id=/subscriptions/bec96e6b-8cfc-4a7b-87bf-...SecurityGroups/newNetworkSecurityGroup, 10s elapsed]
azurerm_network_security_group.nsg: Destruction complete after 10s
azurerm_linux_virtual_machine.vm: Still destroying... [id=/subscriptions/bec96e6b-8cfc-4a7b-87bf-...oft.Compute/virtualMachines/newLinuxVM, 20s elapsed]
azurerm_linux_virtual_machine.vm: Destruction complete after 28s
azurerm_network_interface.network_interface: Destroying... [id=/subscriptions/bec96e6b-8cfc-4a7b-87bf-bfaba37d28ad/resourceGroups/newTFResourceGroup/providers/Microsoft.Network/networkInterfaces/newNetworkInterface]
azurerm_network_interface.network_interface: Still destroying... [id=/subscriptions/bec96e6b-8cfc-4a7b-87bf-.../networkInterfaces/newNetworkInterface, 10s elapsed]
azurerm_network_interface.network_interface: Destruction complete after 11s
azurerm_subnet.subnet: Destroying... [id=/subscriptions/bec96e6b-8cfc-4a7b-87bf-bfaba37d28ad/resourceGroups/newTFResourceGroup/providers/Microsoft.Network/virtualNetworks/newVnet/subnets/newSubnet]
azurerm_public_ip.public_ip: Destroying... [id=/subscriptions/bec96e6b-8cfc-4a7b-87bf-bfaba37d28ad/resourceGroups/newTFResourceGroup/providers/Microsoft.Network/publicIPAddresses/newPublicIP]
azurerm_public_ip.public_ip: Still destroying... [id=/subscriptions/bec96e6b-8cfc-4a7b-87bf-....Network/publicIPAddresses/newPublicIP, 10s elapsed]
azurerm_subnet.subnet: Still destroying... [id=/subscriptions/bec96e6b-8cfc-4a7b-87bf-...tualNetworks/newVnet/subnets/newSubnet, 10s elapsed]
azurerm_subnet.subnet: Destruction complete after 11s
azurerm_virtual_network.vnet: Destroying... [id=/subscriptions/bec96e6b-8cfc-4a7b-87bf-bfaba37d28ad/resourceGroups/newTFResourceGroup/providers/Microsoft.Network/virtualNetworks/newVnet]
azurerm_public_ip.public_ip: Still destroying... [id=/subscriptions/bec96e6b-8cfc-4a7b-87bf-....Network/publicIPAddresses/newPublicIP, 20s elapsed]
azurerm_virtual_network.vnet: Still destroying... [id=/subscriptions/bec96e6b-8cfc-4a7b-87bf-...rosoft.Network/virtualNetworks/newVnet, 10s elapsed]
azurerm_public_ip.public_ip: Destruction complete after 22s
azurerm_virtual_network.vnet: Destruction complete after 11s
azurerm_resource_group.rg: Destroying... [id=/subscriptions/bec96e6b-8cfc-4a7b-87bf-bfaba37d28ad/resourceGroups/newTFResourceGroup]
azurerm_resource_group.rg: Still destroying... [id=/subscriptions/bec96e6b-8cfc-4a7b-87bf-...28ad/resourceGroups/newTFResourceGroup, 10s elapsed]
azurerm_resource_group.rg: Destruction complete after 18s

Destroy complete! Resources: 8 destroyed.
```

-   And that is how you configure the Azure VM.
