output "azuread_service_principal_client_id_azuread_service_principal_client_secret_and_azure_dns_zone_nameservers" {
  description = "AzureAD Service Principal Client ID and Client Secret, Azure DNS Zone and Nameservers"
  value       = module.aks_cluster_and_standard_gke_cluster 
  sensitive   = true
}
