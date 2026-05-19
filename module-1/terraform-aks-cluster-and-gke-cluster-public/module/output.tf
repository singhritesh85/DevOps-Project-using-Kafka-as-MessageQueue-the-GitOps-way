output "azure_managed_identity_client_id_aks" {
  value = azurerm_user_assigned_identity.workload_id.client_id
}

output "azuread_service_principal_client_id_gke" {
  value = azuread_application.gke_kv.client_id
}

output "azuread_service_principal_client_secret_gke" {
  value = azuread_service_principal_password.azuread_sp_secret.value
}

output "dns_zone_name" {
  description = "The name of the Azure DNS Zone."
  value       = azurerm_dns_zone.dns_zone.name
}

output "name_servers" {
  description = "The list of name servers for the Azure DNS Zone."
  value       = azurerm_dns_zone.dns_zone.name_servers
}
