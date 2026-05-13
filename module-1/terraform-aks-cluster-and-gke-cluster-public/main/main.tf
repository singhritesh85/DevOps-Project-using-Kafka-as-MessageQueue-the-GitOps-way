module "aks_cluster_and_standard_gke_cluster" {
  source = "../module"

  prefix = var.prefix
  location = var.location[0]
  env = var.env[0]
  availability_zone = var.availability_zone[0]
  static_dynamic = var.static_dynamic 
  dns_zone_name = var.dns_zone_name

############################################### For GCP Resources ##############################################################

  project_name = var.project_name
  gcp_region = var.gcp_region[1]
  ip_range_subnet = var.ip_range_subnet
  master_ip_range = var.master_ip_range
  min_master_version = var.min_master_version[0]
  node_version = var.node_version[0]
  pods_ip_range = var.pods_ip_range
  services_ip_range = var.services_ip_range
  ip_public_range_subnet = var.ip_public_range_subnet
  machine_type = var.machine_type

############################### To create Azure VM Instance ##################################

  vm_size = var.vm_size[0]
  admin_username = var.admin_username
  admin_password = var.admin_password

################################ To create Azure AKS Cluster #################################

  kubernetes_version_aks = var.kubernetes_version_aks[14]
  action_group_shortname = var.action_group_shortname
  email_address = var.email_address  

}
