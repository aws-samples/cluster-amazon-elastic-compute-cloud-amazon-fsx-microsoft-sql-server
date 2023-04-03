environment                         = "<xxx>"
cluster_name                        = "<xxx>"
# Number of instances in the cluster (1 or 2)
instance_count                      = "2"
# list of subnets in which to create the cluster instances
instance_subnet_map                 = ["<subnet-xxx>","<subnet-yyy>"]
vpc_id                              = "<vpc-xxx>"
# A list of CIDR ranges used by cluster nodes for FCI ports"
fci_ingress_cidr_clustering         = ["<cidr>"]
# A list of CIDR ranges which can connect to port 1433
fci_ingress_cidr_sql                = ["<cidr>"]
# A list of prefix lists which can connect via RDP"
fci_ingress_prefix_rdp              = ["<pl-xxx>"]
# A list of CIDR ranges which can connect via RDP"
fci_ingress_cidr_rdp                = ["<cidr>"]
# AWS encryption key
encryption_key_id                   = "<encryption_key_id>"
encryption_key_arn                  = "arn:aws:kms:<region>:<account_id>:key/<encryption_key_id>"
# AWS Managed AD Directory ID for FSx
active_directory_id                 = "<d-xxx>"
# Subnet name filter to determine available FSx subnets
fsx_subnet_filter                   = "<xxx*>"
# CIDR ranges which are allowed to access the FSx share
fsx_ingress_cidr_ranges             = ["<cidr>"]
# AD domain name
domain_dns_name                     = "<ad_domain>.com"
# AD domain net bios name
domain_net_bios_name                = "<ad_domain>"
# AD groups with RDP access
domain_group_rdp_users              = ["<ad_domain>\\<admin_group>","<ad_domain>\\<rdp_group>"]
# AD groups with administrative access
domain_group_administrators         = ["<ad_domain>\\<admin_group>"]
# AD domain admin user for setting up the cluster
sqlcluster_username_secret_name     = "<domain_admin_username_secret_name>"
# AD domain admin user's password
sqlcluster_password_secret_name     = "<domain_admin_password_secret_name>"
# AD domain user for running the SQL Server services
sqlservice_username_secret_name     = "<domain_user_username_secret_name>"
# AD domain user's password
sqlservice_password_secret_name     = "<domain_user_password_secret_name>"
# Set termination protection for instances
enable_termination_protection       = "false"
# Size of the instances root volume
node_volume_size                    = <###>
# Size of the instances temp volume
tempdb_volume_size                  = <###>
# FSx file system size
fsx_storage_capacity                = <###>
# Instance type
node_instance_type                  = "<xxx.yyy>"
# Windows AMI owner account (self or account id)
ami_owner_account_ids               = ["<account_id>"]
# Windows AMI name filter
windows_ami_name_filter             = "<xxx*>"
# Tags
tag_product                         = "<xxx>"
tag_environment                     = "<xxx>"
