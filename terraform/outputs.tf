output "master_public_ip" {
  description = "IP publique du master"
  value       = azurerm_linux_virtual_machine.master.public_ip_address
}

output "worker_public_ip" {
  description = "IP publique du worker"
  value       = azurerm_linux_virtual_machine.worker.public_ip_address
}
