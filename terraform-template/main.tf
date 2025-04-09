terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}  
}

locals {
  default_tags = {
    env     = "prod"
    created = "terraform"
  }
}

# Virtual Network and Subnet
resource "azurerm_virtual_network" "main" {
  name                = var.vnet_name
  address_space       = var.vnet_address_space
  location            = var.location
  resource_group_name = var.resource_group_name
  tags = local.default_tags  
}

resource "azurerm_subnet" "main" {
  name                 = var.subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = var.subnet_address_prefix
}

#NSG
resource "azurerm_network_security_group" "main" {
  name                = "nsg-allow-subnet-deny-internet"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags = local.default_tags
}

resource "azurerm_network_security_rule" "allow_subnet" {
  name                        = "allow-subnet"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = azurerm_subnet.main.address_prefixes[0]
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.main.name
  resource_group_name         = var.resource_group_name
  
}

resource "azurerm_network_security_rule" "deny_internet" {
  name                        = "deny-internet"
  priority                    = 2000
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "Internet"
  network_security_group_name = azurerm_network_security_group.main.name
  resource_group_name         = var.resource_group_name
  
}

resource "azurerm_network_security_rule" "allow_http_frm_lb" {
  name                        = "allow-http-from-lb"
  priority                    = 3000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = azurerm_subnet.main.address_prefixes[0]
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.main.name
  resource_group_name         = var.resource_group_name
  
}

resource "azurerm_network_security_rule" "allow_outbount_vnet" {
  name                        = "allow-outbound-vnet"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = azurerm_virtual_network.main.address_space[0]
  network_security_group_name = azurerm_network_security_group.main.name
  resource_group_name         = var.resource_group_name
  
}

resource "azurerm_subnet_network_security_group_association" "main" {
  subnet_id                 = azurerm_subnet.main.id
  network_security_group_id = azurerm_network_security_group.main.id
  
  
}

# Network Interface
resource "azurerm_network_interface" "main" {
  count               = var.vm_count
  name                = "nic-${count.index}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags = local.default_tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "main" {
  count                   = var.vm_count
  network_interface_id    = azurerm_network_interface.main[count.index].id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.main.id
  
}

# Public Id and Load Balance
resource "azurerm_public_ip" "lb" {
  name                = "lb-public-ip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = local.default_tags
  
}

resource "azurerm_lb" "main" {
  name = "lb-udacity-devops"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  tags = local.default_tags

  frontend_ip_configuration {
    name                 = "frontend-config"
    public_ip_address_id = azurerm_public_ip.lb.id
    
  }
}

resource "azurerm_lb_backend_address_pool" "main" {
  loadbalancer_id     = azurerm_lb.main.id
  name = "backend-pool"
  
  
}

# Availability Set

resource "azurerm_availability_set" "main" {
  name                = "availability-set"
  location            = var.location
  resource_group_name = var.resource_group_name
  managed             = true
  platform_fault_domain_count = 1
  platform_update_domain_count = 1
  tags = local.default_tags
  
}

# Managed Disk

resource "azurerm_managed_disk" "main" {
  count                = var.vm_count
  name                 = "md-${count.index}"
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 30
  tags = local.default_tags
}

# Virtual Machine
resource "azurerm_linux_virtual_machine" "main" {
  count                 = var.vm_count
  name                  = "vm-${count.index}"
  resource_group_name   = var.resource_group_name
  location              = var.location
  size                  = var.vm_size
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  disable_password_authentication = false
  availability_set_id   = azurerm_availability_set.main.id
  network_interface_ids = [azurerm_network_interface.main[count.index].id]
  tags = local.default_tags

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_id = var.packer_image_id

  depends_on = [azurerm_managed_disk.main]
}

resource "azurerm_virtual_machine_data_disk_attachment" "main" {
  count              = var.vm_count
  managed_disk_id    = azurerm_managed_disk.main[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.main[count.index].id
  lun                = "10"
  caching            = "ReadWrite"
  
}