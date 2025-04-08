variable "resource_group_name" {
  description = "Resource group name"
  type = string
  default = "udacity-devops-rg"
}

variable "location" {
  description = "Location for the resource group"
  type = string
  default = "West Europe"
}

variable "vnet_name" {
  description = "Name of the virtual network"
  type = string
  default = "udacity-devops-vnet"
  
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type = list(string)
  default = [ "10.0.0.0/16" ]
}

variable "subnet_name" {
  description = "Name of the subnet"
  type = string
  default = "udacity-devops-subnet"
  
}

variable "subnet_address_prefix" {
  description = "Prefix address"
  type = list(string)
  default = [ "10.0.1.0/24" ]
}

variable "vm_count" {
  description = "Number of virtual machines to create"
  type = number  
}

variable "vm_size" {
  description = "VM Size"
  type = string
  default = "Standard_B2s"
  
}

variable "admin_username" {
  description = "Admin username for the VM"
  type = string
  default = "adminuser"
  
}

variable "admin_password" {
  description = "Admin password for the VM"
  type = string
  default = "P@ssw0rd1234!"
  sensitive = true
  
}

variable "packer_image_id" {
  description = "Image ID for the VM"
  type = string
  
}