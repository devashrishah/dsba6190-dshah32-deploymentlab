// Tags
locals {
  tags = {
    class      = var.tag_class
    instructor = var.tag_instructor
    semester   = var.tag_semester
  }
}

// Existing Resources

/// Subscription ID

# data "azurerm_subscription" "current" {
# }

// Random Suffix Generator

resource "random_integer" "deployment_id_suffix" {
  min = 100
  max = 999
}

// Resource Group

resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.class_name}-${var.student_name}-${var.environment}-${var.location}-${random_integer.deployment_id_suffix.result}"
  location = var.location

  tags = local.tags
}



// Storage Account

resource "azurerm_storage_account" "storage" {
  name                     = "sto${var.class_name}${var.student_name}${var.environment}${random_integer.deployment_id_suffix.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  account_kind = "StorageV2"

  is_hns_enabled                = true
  public_network_access_enabled = false

  network_rules {
    default_action             = "Deny"
    virtual_network_subnet_ids = [azurerm_subnet.subnet.id]
    bypass                     = ["AzureServices"]
  }

  tags = local.tags
}



// VirtualNet 

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.class_name}-${var.student_name}-${var.environment}-${var.location}-${random_integer.deployment_id_suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
}


//Subnet

resource "azurerm_subnet" "subnet" {
  name                 = "subnet-app"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]

  service_endpoints = [
    "Microsoft.Sql",
    "Microsoft.Storage"
  ]
}



//SQL Server

resource "azurerm_mssql_server" "sql_server" {
  name                = "sql-${var.class_name}-${var.student_name}-${var.environment}-${random_integer.deployment_id_suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  version                      = "12.0"
  administrator_login          = var.sql_admin_user
  administrator_login_password = var.sql_admin_password

  public_network_access_enabled = true


  tags = local.tags
}



//SQL Database

resource "azurerm_mssql_database" "sql_db" {
  name      = "db-${var.class_name}-${var.student_name}-${var.environment}-${random_integer.deployment_id_suffix.result}"
  server_id = azurerm_mssql_server.sql_server.id

  sku_name = "Basic"

  tags = local.tags
}



//VNet Rule
resource "azurerm_mssql_virtual_network_rule" "sql_vnet_rule" {
  name      = "sql-vnet-rule"
  server_id = azurerm_mssql_server.sql_server.id
  subnet_id = azurerm_subnet.subnet.id

  depends_on = [
    azurerm_mssql_server.sql_server,
    azurerm_subnet.subnet
  ]
}