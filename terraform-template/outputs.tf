# outputs.tf
output "load_balancer_public_ip" {
  value = azurerm_public_ip.lb.ip_address
}

output "resource_group_name" {
  value = var.resource_group_name
}

output "virtual_network_name" {
  value = azurerm_virtual_network.main.name
}

output "subnet_name" {
  value = azurerm_subnet.main.name
}

output "vm_names" {
  value = [for vm in azurerm_linux_virtual_machine.main : vm.name]
}