# RÉSULTATS DU DÉPLOIEMENT (IPs PUBLIQUES)


output "master_public_ip" {
  description = "L'adresse IP publique du Node Master"
  value       = azurerm_public_ip.pip_master.ip_address
}

output "worker_public_ip" {
  description = "L'adresse IP publique du Node Worker"
  value       = azurerm_public_ip.pip_worker.ip_address
}
