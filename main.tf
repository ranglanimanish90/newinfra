module "key-vault" {
  for_each                      = local.keyvaultcollection
  source                        = "../../modules/key-vault"
  subscription_id               = var.subscription_id
  resource_group                = var.resource_group
  resource_name                 = each.key
  location                      = "eastus1"
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  public_network_access_enabled = lookup(each.value, "public_network_access_enabled", false)
  network_acls_default_action   = lookup(each.value, "network_acls_default_action", "Deny")
  network_acls_bypass           = lookup(each.value, "network_acls_bypass", "AzureServices")
  purge_protection_enabled      = lookup(each.value, "purge_protection_enabled", true)
  enable_rbac_authorization     = lookup(each.value, "enable_rbac_authorization", true)
  soft_delete_retention_days    = lookup(each.value, "soft_delete_retention_days", 90)
  sku_name                      = lookup(each.value, "sku_name", "standard")
}
