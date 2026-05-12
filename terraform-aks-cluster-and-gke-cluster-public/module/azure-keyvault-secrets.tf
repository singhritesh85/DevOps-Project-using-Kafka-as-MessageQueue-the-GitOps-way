resource "azurerm_key_vault" "key_vault_postgresql" {
  name                        = "${var.prefix}"
  location                    = azurerm_resource_group.vnetconnection_rg.location
  resource_group_name         = azurerm_resource_group.vnetconnection_rg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  soft_delete_retention_days  = 7
  rbac_authorization_enabled  = true

#  access_policy {
#    tenant_id               = data.azurerm_client_config.current.tenant_id
#    object_id               = data.azurerm_client_config.current.object_id
#    key_permissions         = ["Get", "List", "Delete", "Purge"]
#    secret_permissions      = ["Get", "List", "Set", "Delete", "Purge"]
#  }
}

resource "random_password" "postgresql_password" {
  length           = 16
  special          = true
  override_special = "_!%^@"
  min_upper        = 2
  min_lower        = 2
  min_numeric      = 2
}

resource "azurerm_key_vault_secret" "postgresql_password" {
  name         = "${var.prefix}-postgresql-server-password"
  value        = random_password.postgresql_password.result
  key_vault_id = azurerm_key_vault.key_vault_postgresql.id
  depends_on = [azurerm_role_assignment.key_vault_role_assignment]
}

resource "azurerm_role_assignment" "key_vault_role_assignment" {
  scope                = azurerm_key_vault.key_vault_postgresql.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

### Create User Assigned Managed Identity
resource "azurerm_user_assigned_identity" "workload_id" {
  name                = "${var.prefix}-aks-workload-id"
  location            = azurerm_resource_group.vnetconnection_rg.location
  resource_group_name = azurerm_resource_group.vnetconnection_rg.name
}

### Allow User Assigned Managed Identity to Read Key Vault Secrets 
resource "azurerm_role_assignment" "kv_access" {
  principal_id         = azurerm_user_assigned_identity.workload_id.principal_id
  role_definition_name = "Key Vault Secrets User"
  scope                = azurerm_key_vault.key_vault_postgresql.id
}

### Create Federated Identity Credential for AKS
resource "azurerm_federated_identity_credential" "fic" {
  name                      = "${var.prefix}-postgres-federation-aks"
  user_assigned_identity_id = azurerm_user_assigned_identity.workload_id.id
  audience = ["api://AzureADTokenExchange"]
  issuer   = azurerm_kubernetes_cluster.aks_cluster.oidc_issuer_url
  subject  = "system:serviceaccount:postgresql:postgres-sa"
}

### Create AzureAD Application for GKE
resource "azuread_application" "gke_kv" {
  display_name = "${var.prefix}-gke-azure-kv"
}

### Create AzureAD Service Principal for GKE
resource "azuread_service_principal" "gke_kv_sp" {
  client_id = azuread_application.gke_kv.client_id
}

### Create a Password for the Azure Service Principal
resource "azuread_service_principal_password" "azuread_sp_secret" {
  service_principal_id = azuread_service_principal.gke_kv_sp.id
  display_name         = "azuread-sp-password-for-gke"
  end_date             = "2027-01-01T00:00:00Z"
}

### Allow Azure Key Vault Access to AzureAD Service Principal for GKE
resource "azurerm_role_assignment" "kv_access_sp_for_gke" {
  scope                = azurerm_key_vault.key_vault_postgresql.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azuread_service_principal.gke_kv_sp.object_id
}
