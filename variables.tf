variable "environment" {
  type        = string
  description = "The environment name where these resources are deployed"
}

variable "windows_ami_name_filter" {
  type        = string
  description = "Filter used to determine the latest AMI to use on FCI nodes"
  default     = "sqlserver*"
}

variable "ami_owner_account_ids" {
  type        = list
  description = "Allowlist of AWS accounts that can provide an FCI node AMI"
  default     = [""]
}

variable "cluster_name" {
  type        = string
  description = "Short name describing the cluster"

  validation {
    condition     = length(var.cluster_name) <= 13
    error_message = "Windows limits FCI and SQL cluster names to 15 characters in length. Instances are appended with two digits to identify each cluster node."
  }
}

variable "node_instance_type" {
  type        = string
  description = "EC2 instance type used for FCI nodes"
  default     = "m6i.large"
}

variable "node_volume_size" {
  type        = number
  description = "Size in GBs of the FCI instance root device volume"
  default     = 100
}

variable "instance_subnet_map" {
  type        = list(string)
  description = "List of IDs each FCI instance should reside in. Item 0 in this list refers to the Primary FCI and is mapped sequentially. This list must contain the same number of subnet ids as instance count."
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC where FCI instances will run"
}

variable "fci_ingress_cidr_sql" {
  type        = list(string)
  description = "A list of CIDR ranges which can connect to port 1433"
  default     = []
}

variable "fci_ingress_prefix_sql" {
  type        = list(string)
  description = "A list of prefix lists which can connect to port 1433"
  default     = []
}

variable "fci_ingress_cidr_clustering" {
  type        = list(string)
  description = "A list of CIDR ranges used by cluster nodes for FCI ports"
  default     = []
}

variable "fci_ingress_prefix_rdp" {
  type        = list(string)
  description = "A list of prefix lists which can connect via RDP"
  default     = []
}

variable "fci_ingress_cidr_rdp" {
  type        = list(string)
  description = "A list of CIDR ranges which can connect via RDP"
  default     = null
}

variable "instance_count" {
  type        = number
  description = "How many FCI instances should be configured in this cluster?"
  default     = 2

  validation {
    condition     = var.instance_count <= 2
    error_message = "This module expects no more than 2 instances as only 2 availability zones are used for this FCI cluster."
  }
}

variable "encryption_key_id" {
  type        = string
  description = "KMS Key ID used to encrypt the FCI resources"
}

variable "encryption_key_arn" {
  type        = string
  description = "KMS Key ARN used to encrypt the FCI resources"
}

variable "active_directory_id" {
  type        = string
  description = "The Active Directory DS ID that should be used for FSx resources"
}

variable "fsx_subnet_filter" {
  type        = string
  description = "Subnet name filter used to identify FSx subnet ids"
}

variable "fsx_storage_capacity" {
  type        = number
  description = "Storage capacity in GBs provisioned for this cluster"
  default     = 32
}

variable "fsx_throughput_capacity" {
  type        = number
  description = "MB/s provisioned throughput"
  default     = 64
}

variable "fsx_ingress_cidr_ranges" {
  type        = list(string)
  description = "CIDR ranges which are allowed to access the FSx share"
  default     = []
}

variable "domain_group_rdp_users" {
  type        = list
  description = "List of user groups which are allowed RDP access to the FCI instances"
}

variable "domain_group_administrators" {
  type        = list
  description = "List of user groups which are granted administrative access to FCI instances"
}

variable "domain_dns_name" {
  type        = string
  description = "The DNS name of the Active Directory Domain"
}

variable "domain_net_bios_name" {
  type        = string
  description = "NetBIOS name of the Active Directory domain"
}

variable "sqlserver_product_key" {
  type        = string
  description = "The licence key used by SQLServer to determine the version to install. By default, Developer edition is installed."
  default     = "22222-00000-00000-00000-00000"
}

variable "enable_termination_protection" {
  type        = bool
  description = "Should critical resources have termination protection turned on to protect against accidental deletion?"
  default     = true
}

variable "sql_tcp_port" {
  type        = number
  description = "The TCP port used for SQL connections"
  default     = 1433
}

variable "fci_health_check_port" {
  type        = number
  description = "The port used for FCI health checking"
  default     = 59997
}

variable "tempdb_volume_size" {
  type        = number
  description = "Number of GBs allocated to the tempdb EBS volume"
  default     = 16
}

variable "tempdb_volume_type" {
  type        = string
  description = "EBS volume type used for the temp db volume"
  default     = "gp3"
}

variable "tempdb_volume_iops" {
  type        = number
  description = "How many IOPS are provisioned to the tempdb EBS volume"
  default     = 3000
}

variable "sqlcluster_username_secret_name" {
  type        = string
  description = "Name of the Secrets Manager secret storing the SQL Cluster admin username. Must be a domain admin"
}

variable "sqlcluster_password_secret_name" {
  type        = string
  description = "Name of the Secrets Manager secret storing the SQL Cluster admin password"
}

variable "sqlservice_username_secret_name" {
  type        = string
  description = "Name of the Secrets Manager secret storing the SQL services username. Must have administrative rights on the instances."
}

variable "sqlservice_password_secret_name" {
  type        = string
  description = "Name of the Secrets Manager secret storing the SQL services password"
}

variable "metadata_tags" {
  description = "Whether or not the Instance Metadata Endpoint returns information about the instance's tags. Should be either `enabled` or `disabled`."
  type        = string
  default     = "enabled"
}

variable "metadata_endpoint" {
  description = "Whether or not the Instance Metadata Endpoint is enabled. Should be either `enabled` or `disabled`."
  type        = string
  default     = "enabled"
}

#--------------------------------------------------------------
# Global Tags
#--------------------------------------------------------------
variable "tag_product" {
  description = "Family of resource being deployed"
  type        = string
}

variable "tag_environment" {
  description = "Envrionment in which resources are deployed (e.g., nonprod)"
  type        = string
}

variable "extra_tags" {
  description = "A map of additional tag/value pairs to add to the resources"
  type        = map(string)
  default     = {}
}
