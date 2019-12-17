variable "location" {
  type        = string
  description = "The location where the Managed Kubernetes Cluster should be created. Changing this forces a new resource to be created"
  default     = "uksouth"
}

variable "cluster_name" {
  type        = string
  description = "AKS cluster name"
  default     = "aks"
}

variable "resource_group" {
  type        = string
  description = "Specifies the Resource Group where the Managed Kubernetes Cluster should exist. Changing this forces a new resource to be created"
  default     = ""
}

variable "service_principal_client_id" {
  type        = string
  description = "The Client ID for the Service Principal"
  default     = ""
}

variable "service_principal_client_secret" {
  type        = string
  description = "The Client Secret for the Service Principal"
  default     = ""
}

variable "admin_username" {
  type        = string
  description = "The Admin Username for the Cluster. Changing this forces a new resource to be created"
  default     = "aksuser"
}

variable "ssh_public_key" {
  type        = string
  description = "The Public SSH Key used to access the cluster. Changing this forces a new resource to be created"
  default     = ""
}

variable "default_node_pool_vm_size" {
  type        = string
  description = "The size of each VM in the Agent Pool (e.g. Standard_F1). Changing this forces a new resource to be created"
  default     = "Standard_DS2_v2"
}

variable "default_node_pool_os_disk_size_gb" {
  type        = number
  description = "The Agent Operating System disk size in GB. Changing this forces a new resource to be created"
  default     = 100
}

variable "default_node_pool_min_size" {
  type        = number
  description = "Minimum number of nodes for auto-scaling"
  default     = 1
}

variable "default_node_pool_max_size" {
  type        = number
  description = "Maximum number of nodes for auto-scaling."
  default     = 3
}

variable "kubernetes_version" {
  type        = string
  description = "Version of Kubernetes specified when creating the AKS managed cluster. If not specified, the latest recommended version will be used at provisioning time (but won't auto-upgrade)"
  default     = "1.14.8"
}

#https://github.com/cloudposse/terraform-null-label.git
variable "context" {
  type = object({
    namespace           = string
    environment         = string
    stage               = string
    name                = string
    enabled             = bool
    delimiter           = string
    attributes          = list(string)
    label_order         = list(string)
    tags                = map(string)
    additional_tag_map  = map(string)
    regex_replace_chars = string
  })
  default = {
    namespace           = ""
    environment         = ""
    stage               = ""
    name                = ""
    enabled             = true
    delimiter           = ""
    attributes          = []
    label_order         = []
    tags                = {}
    additional_tag_map  = {}
    regex_replace_chars = ""
  }
  description = "Default context to use for passing state between label invocations"
}