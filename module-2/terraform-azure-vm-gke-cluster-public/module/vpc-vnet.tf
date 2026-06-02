###############################################Create Azure Resource Group###############################################################

resource "azurerm_resource_group" "vnetconnection_rg" {
  name     = "${var.prefix}-rg"
  location = var.location
}

################################ Azure VNet ############################################

resource "azurerm_virtual_network" "vnet-1" {
  name                = "VNet1"
  resource_group_name = azurerm_resource_group.vnetconnection_rg.name
  location            = azurerm_resource_group.vnetconnection_rg.location
  address_space       = ["10.224.0.0/12"]
}

resource "azurerm_subnet" "vnet1_subnet" {
  name                 = "Subnet-1"
  resource_group_name  = azurerm_resource_group.vnetconnection_rg.name
  virtual_network_name = azurerm_virtual_network.vnet-1.name
  address_prefixes     = ["10.224.0.0/16"]
}

resource "azurerm_subnet" "vnet1_gtwsubnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.vnetconnection_rg.name
  virtual_network_name = azurerm_virtual_network.vnet-1.name
  address_prefixes     = ["10.225.0.0/16"]
}

resource "azurerm_subnet" "mysql_flexible_server_subnet" {
  name                 = "${var.prefix}-mysql-flexible-server-subnet"
  resource_group_name  = azurerm_resource_group.vnetconnection_rg.name
  virtual_network_name = azurerm_virtual_network.vnet-1.name
  address_prefixes     = ["10.226.0.0/16"]
  service_endpoints    = ["Microsoft.Storage"]
  delegation {
    name = "mysql-delegation"
    service_delegation {
      name = "Microsoft.DBforMySQL/flexibleServers"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_subnet" "inbound_subnet" {
  name                 = "inbound-subnet"
  resource_group_name  = azurerm_resource_group.vnetconnection_rg.name
  virtual_network_name = azurerm_virtual_network.vnet-1.name
  address_prefixes     = ["10.227.0.0/24"]
  delegation {
    name = "dns-resolver-delegation"
    service_delegation {
      name    = "Microsoft.Network/dnsResolvers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_subnet" "outbound_subnet" {
  name                 = "outbound-subnet"
  resource_group_name  = azurerm_resource_group.vnetconnection_rg.name
  virtual_network_name = azurerm_virtual_network.vnet-1.name
  address_prefixes     = ["10.228.0.0/24"]
  delegation {
    name = "dns-resolver-delegation"
    service_delegation {
      name    = "Microsoft.Network/dnsResolvers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

# Create VPC in GCP
resource "google_compute_network" "gke_vpc" {
  name = "${var.prefix}-vpc"
  auto_create_subnetworks = false
}

# Create Private Subnet for VPC in GCP
resource "google_compute_subnetwork" "gke_subnet" {
  name = "${var.prefix}-${var.gcp_region}-private-subnet"
  region = var.gcp_region
  network = google_compute_network.gke_vpc.id
  private_ip_google_access = true           ### VMs in this Subnet without external IP
  ip_cidr_range = var.ip_range_subnet
  secondary_ip_range {
    range_name    = "secondary-ip-range-for-pods"
    ip_cidr_range = var.pods_ip_range
  }
  secondary_ip_range {
    range_name    = "secondary-ip-range-for-service"
    ip_cidr_range = var.services_ip_range
  }
}

# Create Public Subnet for VPC in GCP
resource "google_compute_subnetwork" "gke_public_subnet" {
  name = "${var.prefix}-${var.gcp_region}-public-subnet"
  region = var.gcp_region
  network = google_compute_network.gke_vpc.id
  ip_cidr_range = var.ip_public_range_subnet
}

# Create GCP Cloud Router
resource "google_compute_router" "nat_router" {
  name    = "${var.prefix}-nat-router"
  region  = var.gcp_region
  network = google_compute_network.gke_vpc.name
}

# Create GCP Cloud NAT
resource "google_compute_router_nat" "nat_gateway" {
  name                          = "${var.prefix}-nat-gateway"
  router                        = google_compute_router.nat_router.name
  region                        = google_compute_router.nat_router.region
  nat_ip_allocate_option        = "AUTO_ONLY" ### "MANUAL_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = google_compute_subnetwork.gke_subnet.name
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}
