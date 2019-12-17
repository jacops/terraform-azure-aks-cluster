provider "azurerm" {
  version = "~> 1.37"
}

provider "azuread" {
  version = "~> 0.7"
}

provider "null" {
  version = "~> 2.1"
}

module "label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=0.16.0"
  name       = var.cluster_name

  context = var.context
}

locals {
  azurerm_resource_group          = coalesce(var.resource_group,                  element(concat(azurerm_resource_group.aks.*.name, list("")), 0))
  service_principal_client_id     = coalesce(var.service_principal_client_id,     element(concat(azuread_service_principal.aks.*.application_id, list("")), 0))
  service_principal_client_secret = coalesce(var.service_principal_client_secret, element(concat(azuread_application_password.aks.*.value, list("")), 0))
  ssh_public_key                  = coalesce(var.ssh_public_key,                  element(concat(tls_private_key.aks.*.public_key_openssh, list("")), 0))
}

resource "azurerm_resource_group" "aks" {
  name     = "${module.label.id}-rg"
  location = var.location

  tags = module.label.tags

  count = var.resource_group == "" ? 1 : 0
}

resource "random_string" "aks_sp_password" {
  length = 32

  count = var.service_principal_client_id == "" ? 1 : 0
}

resource "azuread_application" "aks" {
  name = module.label.id

  count = var.service_principal_client_id == "" ? 1 : 0
}

resource "azuread_service_principal" "aks" {
  application_id = element(concat(azuread_application.aks.*.application_id, list("")), 0)

  count = var.service_principal_client_id == "" ? 1 : 0
}

resource "azuread_application_password" "aks" {
  value                 = element(concat(random_string.aks_sp_password.*.result, list("")), 0)
  application_object_id = element(concat(azuread_application.aks.*.object_id, list("")), 0)
  end_date_relative     = "8760h"

  count = var.service_principal_client_id == "" ? 1 : 0
}

resource "tls_private_key" "aks" {
  algorithm = "RSA"
  rsa_bits  = 4096

  count = var.ssh_public_key == "" ? 1 : 0
}

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = module.label.id
  resource_group_name = local.azurerm_resource_group
  location            = var.location
  dns_prefix          = module.label.id

  kubernetes_version  = var.kubernetes_version

  role_based_access_control {
    enabled = true
  }

  service_principal {
    client_id     = local.service_principal_client_id
    client_secret = local.service_principal_client_secret
  }

  default_node_pool {
    name                = "nodes"
    vm_size             = var.default_node_pool_vm_size
    os_disk_size_gb     = var.default_node_pool_os_disk_size_gb
    min_count           = var.default_node_pool_min_size
    max_count           = var.default_node_pool_max_size
    type                = "VirtualMachineScaleSets"
    enable_auto_scaling = true
  }

  linux_profile {
    admin_username = var.admin_username
    ssh_key {
      key_data = local.ssh_public_key
    }
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "calico"
  }

  tags = module.label.tags
}
