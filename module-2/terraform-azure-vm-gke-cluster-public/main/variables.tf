variable "location" {
  type = list
  description = "Provide the Location for Resources to be created"
}

variable "subscription_id" {
  type = string
  description = "Provide the Azure Subscription ID"
}

variable "tenant_id" {
  type = string
  description = "Provide the Azure Tenant ID"
}

variable "availability_zone" {
  type = list
  description = "Provide the Availability Zone into which the Azure VMs to be created"
}

variable "static_dynamic" {
  type = list
  description = "Provide IP to be created is Public or Static"
}

variable "dns_zone_name" {
  description = "Provide the Name for Azure DNS Zone to be created"
  type = string
}

######################################################## Variables to create GCP Resources #############################################################

variable "project_name" {
  description = "Provide the project name in GCP Account"
  type = string
}

variable "gcp_region" {
  description = "Provide the GCP Region in which Resources to be created"
  type = list
}

variable "prefix" {
  description = "Provide the prefix used for the project"
  type = string
}

variable "ip_range_subnet" {
  description = "Provide the IP range for Private Subnet"
  type = string
}

variable "master_ip_range" {
  description = "IP address range for the master network of a GKE cluster"
  type = string
}

variable "min_master_version" {
  description = "Provide Kubernetes Version of Control Plane"
  type = list
}

variable "node_version" {
  description = "Provide Kubernetes Version of Worker Nodes"
  type = list
}

variable "pods_ip_range" {
  description = "Secondary IP address range using which Pod will be created"
  type = string
}

variable "services_ip_range" {
  description = "Secondary IP address range using which Services will be created"
  type = string
}

variable "ip_public_range_subnet" {
  description = "Provide the IP range for Public Subnet"
  type = string
}

variable "machine_type" {
  description = "Provide the Machine Type for VM Instances"
  type = list
}

variable "env" {
  description = "Provide the Environment into which the resources to be created"
  type = list
}

######################################################## Variables to create Azure VM Instance ##########################################################

variable "vm_size" {
  type = list
  description = "Provide the Size of the Azure VM"
}

variable "admin_username" {
  type = string
  description = "Provid the Administrator Username"
}

variable "admin_password" {
  type = string
  description = "Provide the Administrator Password"
}
