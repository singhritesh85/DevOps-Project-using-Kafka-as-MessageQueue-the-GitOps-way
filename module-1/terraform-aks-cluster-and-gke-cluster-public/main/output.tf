output "azure_managed_identity_client_id_and_azure_dns_zone_nameservers" {
  description = "Azure Managed Identity Client ID, Azure DNS Zone and Nameservers"
  value       = module.aks_cluster_and_standard_gke_cluster 
  sensitive   = true
}
