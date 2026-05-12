output "azure_managed_identity_client_id" {
  description = "Azure Managed Identity Client ID"
  value       = module.aks_cluster_and_standard_gke_cluster 
  sensitive   = true
}
