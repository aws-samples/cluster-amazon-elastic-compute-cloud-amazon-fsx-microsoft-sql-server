module "fsx" {
  source                   = "./module-fsx"
  active_directory_id      = var.active_directory_id
  fsx_attach_subnet_filter = var.fsx_subnet_filter
  fsx_kms_key              = var.encryption_key_arn
  fsx_name                 = "${var.environment}_${var.cluster_name}_fci"
  storage_capacity         = var.fsx_storage_capacity
  throughput_capacity      = var.fsx_throughput_capacity
  vpc_id                   = var.vpc_id
  deployment_type          = var.instance_count == 1 ? "SINGLE_AZ_1" : "MULTI_AZ_1"
  fsx_ingress_cidr_blocks  = var.fsx_ingress_cidr_ranges
  preferred_subnet_id      = var.instance_subnet_map[0]
  tag_environment          = var.tag_environment
  tag_product              = var.tag_product
}
