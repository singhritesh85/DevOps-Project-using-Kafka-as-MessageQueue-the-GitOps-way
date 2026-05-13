############################################### Parameters for Azure VNet and Site-to-Site VPN##################################################

prefix = "multicloud"
location = ["East US", "East US 2", "Central India", "Central US"]
env = ["dev", "stage", "prod"]
static_dynamic = ["Static", "Dynamic"]
availability_zone = [1] ### Provide the Availability Zones into which the VM to be created.

subscription_id = "5XXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
tenant_id = "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"

dns_zone_name = "singhritesh85.com"

############################################### Parameters to create GCP Resources ###############################################

project_name = "XXXX-XXXXXXX-XXXXXX"  ### Provide the GCP Account Project ID.
gcp_region = ["us-east1", "us-central1", "asia-south2", "asia-south1", "us-west1"]
ip_range_subnet = "10.10.0.0/20"
master_ip_range = "172.16.0.0/28"
min_master_version = ["1.34.6", "1.32.6", "1.30.12"] ###["v1.33.4-gke.1134000", "v1.32.4-gke.1415000", "v1.30.12-gke.1246000"]
node_version = ["1.34.6", "1.32.6", "1.30.12"]       ###["v1.33.4-gke.1134000", "v1.32.4-gke.1415000", "v1.30.12-gke.1246000"]
pods_ip_range = "172.17.0.0/16"
services_ip_range = "172.19.0.0/16"
ip_public_range_subnet = "10.20.0.0/20"
machine_type = ["n1-standard-1", "e2-small", "e2-medium", "n2-standard-4", "c2-standard-4", "c3-standard-4"]

############################## Parameter for Azure VM Instance ###############################

vm_size = ["Standard_B2s", "Standard_B2ms", "Standard_B4ms", "Standard_DS1_v2"]
admin_username = "ritesh"
admin_password = "Password@#795"

############################## Parameter for Azure AKS Cluster ###############################

kubernetes_version_aks = ["1.26.6", "1.26.10", "1.27.3", "1.27.7", "1.28.0", "1.28.3", "1.28.5", "1.29.0", "1.29.2", "1.30.0", "1.30.12", "1.31.8", "1.32.4", "1.33.0", "1.34.6"]
action_group_shortname = "aks-action"
email_address = "abc@gmail.com"  ### Provide Group Email Address on which notification should be send.
