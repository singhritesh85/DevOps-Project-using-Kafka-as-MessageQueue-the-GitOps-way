output "azure_managed_identity_client_id_aks" {
  value = azurerm_user_assigned_identity.workload_id.client_id
}

output "azuread_service_principal_client_id_gke" {
  value = azuread_application.gke_kv.client_id
}

output "azuread_service_principal_client_secret_gke" {
  value = azuread_service_principal_password.azuread_sp_secret.value
}
