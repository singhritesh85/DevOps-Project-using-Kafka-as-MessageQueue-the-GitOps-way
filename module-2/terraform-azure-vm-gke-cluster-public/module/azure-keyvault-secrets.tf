# Data source to access the configuration of the AzureRM provider
data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "key_vault_keystore_truststore" {
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

resource "random_password" "keystore_truststore_password" {
  length           = 16
  special          = true
  override_special = "_!%^@"
  min_upper        = 2
  min_lower        = 2
  min_numeric      = 2
}

resource "azurerm_key_vault_secret" "keystore_truststore_password" {
  name         = "${var.prefix}-keystore-truststore-server-password"
  value        = random_password.keystore_truststore_password.result
  key_vault_id = azurerm_key_vault.key_vault_keystore_truststore.id
  depends_on = [azurerm_role_assignment.key_vault_role_assignment]
}

resource "azurerm_role_assignment" "key_vault_role_assignment" {
  scope                = azurerm_key_vault.key_vault_keystore_truststore.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
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
  scope                = azurerm_key_vault.key_vault_keystore_truststore.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azuread_service_principal.gke_kv_sp.object_id
}

### Allow Azure Key Vault Access to AzureAD Service Principal for Azure DevOps 
data "azuread_service_principal" "azure_devops_sp" {
  display_name = "DevOpsDemoServicePrincipal"
}

resource "azurerm_role_assignment" "kv_secrets_user" {
  scope                = azurerm_key_vault.key_vault_keystore_truststore.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = data.azuread_service_principal.azure_devops_sp.object_id
}
