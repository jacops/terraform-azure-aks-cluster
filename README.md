# AKS cluster

Terraform module for creating Azure Kubernetes Service

> Currently this cluster only works in auto scaling mode (which is a DevOps way)

## Sample usage

The snippet below will create for you:
* resource group
* AD service principal
* SSH key **(Not recommended for production)**

```hcl-terraform
module "aks" {
  source   = "jacops/aks-cluster"
  location = "uksouth"
}
```

## Advanced usage

```hcl-terraform
module "label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=0.16.0"

  namespace   = "jacops"
  environment = "dev"
}

resource "azurerm_resource_group" "aks" {
  name     = "${module.label.id}-rg"
  location = var.location

  tags = module.label.tags
}


module "aks" {
  source = "jacops/aks-cluster"

  location       = azurerm_resource_group.aks.location
  resource_group = azurerm_resource_group.aks.name
  
  service_principal_client_id     = "<service_principal_client_id provided by AD administrator>"
  service_principal_client_secret = "<service_principal_client_secret provided by AD administrator>"
  
  ssh_public_key = "<ssh_public_key signed by your orgnisation>" 
  
  default_node_pool_min_size = 2
  default_node_pool_max_size = 10

  context        = module.label.context 
}
```
