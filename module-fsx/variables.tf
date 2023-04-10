# FSx Module Variables

variable "fsx_name" {
  type        = string
  description = "The name associated with this fsx"
}

variable "fsx_kms_key" {
  type        = string
  description = "kms key for fsx"

}
variable "storage_capacity" {
  type        = string
  description = "storage capacity for fsx"
}

variable "storage_type" {
  type        = string
  description = "storage type for fsx"
  default     = "SSD"
}
variable "throughput_capacity" {
  type        = string
  description = "throughput capacity for fsx"
}

variable "deployment_type" {
  type        = string
  description = "deployment_type for fsx"
  default     = "SINGLE_AZ_1"
}

variable "active_directory_id" {
  type        = string
  description = "AD ID"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC"
}

variable "fsx_attach_subnet_filter" {
  type        = string
  description = "subnet filter to place fsx"
}

variable "fsx_ingress_cidr_blocks" {
  description = "List of CIDR blocks allowed to access the FSx"
  type        = list(string)
  default     = []
}

variable "fsx_ingress_prefix_ids" {
  description = "Prefix list ids which are allowed ingress smb connections"
  type        = list(string)
  default     = []
}

variable "preferred_subnet_id" {
  description = "Subnet ID of the preferred primary subnet when running Multi-AZ. (Optional) defaults will be selected if not specified"
  type        = string
  default     = ""
}

# Tags

variable "tag_product" {
  description = "Family of resource being deployed"
  type        = string
}

variable "tag_environment" {
  description = "Environment in which resources are deployed (e.g., nonprod)"
  type        = string
}

variable "extra_tags" {
  description = "A map of additional tag/value pairs to add to the resources"
  type        = map(string)
  default     = {}
}
