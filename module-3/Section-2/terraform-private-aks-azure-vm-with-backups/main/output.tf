output "aks_k8s_management_and_azure_vm_instance_details" {
  description = "Details of created AKS Cluster and K8S Management Azure VM Instance"
  value       = module.aks_confluent 
  sensitive   = true
}
