data "aws_ami" "windows" {
  most_recent = true
  owners      = var.ami_owner_account_ids

  filter {
    name   = "name"
    values = [var.windows_ami_name_filter]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "random_string" "cluster_id" {
  length  = 5
  special = false
  lower   = false
  upper   = true
  numeric = false
}

resource "aws_instance" "fci" {
  count                   = var.instance_count
  ami                     = data.aws_ami.windows.id
  instance_type           = var.node_instance_type
  key_name                = aws_key_pair.fci_instance.key_name
  iam_instance_profile    = aws_iam_instance_profile.fci_instance.name
  disable_api_termination = var.enable_termination_protection

  user_data = templatefile("${path.module}/scripts/instance_setup.tftpl", {
    cluster_name                = upper(var.cluster_name)
    cluster_id                  = random_string.cluster_id.result
    cluster_node_index          = count.index + 1
    environment_name            = var.environment
    cluster_size                = var.instance_count
    primary_instance            = count.index == 0
    fsx_admin_endpoint          = module.fsx.remote_admin_endpoint
    fsx_net_bios_name           = module.fsx.fsx_name
    secondary_ips               = flatten([for k, v in flatten(data.aws_network_interface.instance_interfaces.*.private_ips) : v if k % 3 != 0])
    network_primary_ip          = element(data.aws_network_interface.instance_interfaces.*.private_ips, count.index)[0]
    network_default_gateway     = replace(element(data.aws_network_interface.instance_interfaces.*.private_ips, count.index)[0], "/\\.[\\d]+$/", ".1")
    domain_group_administrators = join(",", formatlist("\"%s\"", var.domain_group_administrators)),
    domain_group_rdp_users      = join(",", formatlist("\"%s\"", var.domain_group_rdp_users)),
    domain_dns_name             = var.domain_dns_name
    domain_net_bios_name        = var.domain_net_bios_name
    sqlserver_product_key       = var.sqlserver_product_key
    fci_health_check_port       = var.fci_health_check_port
    sql_sa_password             = random_password.sa_password.result
    sqlcluster_user             = { username_secret = var.sqlcluster_username_secret_name, password_secret = var.sqlcluster_password_secret_name }
    sqlservice_user             = { username_secret = var.sqlservice_username_secret_name, password_secret = var.sqlservice_password_secret_name }
  })

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.fci_instance[count.index].id
  }

  root_block_device {
    encrypted   = true
    kms_key_id  = var.encryption_key_arn
    volume_size = var.node_volume_size
    volume_type = "gp3"
  }

  ebs_block_device {
    device_name = "/dev/sda2"
    encrypted   = true
    kms_key_id  = var.encryption_key_arn
    volume_size = var.tempdb_volume_size
    volume_type = var.tempdb_volume_type
    iops        = var.tempdb_volume_iops
  }

  metadata_options {
    http_endpoint          = var.metadata_endpoint
    instance_metadata_tags = var.metadata_tags
  }

  tags = merge(local.global_tags, {
    Name           = format("%s.%s.%s.%s%02d", "sqlfci", var.environment, "db", upper(var.cluster_name), (count.index + 1))
    SQLClusterName = upper(var.cluster_name)
    FCICluster     = random_string.cluster_id.result
    FCIRole        = var.instance_count > 1 ? (count.index == 0 ? "Primary" : "Secondary") : "Disabled"
  })
}

resource "aws_network_interface" "fci_instance" {
  count             = var.instance_count
  subnet_id         = var.instance_subnet_map[count.index]
  private_ips_count = 2
  security_groups   = [aws_security_group.fci_local.id]
  tags              = local.global_tags
}

data "aws_network_interface" "instance_interfaces" {
  depends_on = [aws_network_interface.fci_instance]
  count      = var.instance_count
  id         = aws_network_interface.fci_instance[count.index].id
}

resource "aws_security_group" "fci_local" {
  name        = "${var.cluster_name}SqlServerFCI"
  description = "Allow access to FCI instances from trusted networks"
  vpc_id      = var.vpc_id
  tags        = local.global_tags

  ingress {
    description     = "Allow SQL Connections"
    from_port       = var.sql_tcp_port
    to_port         = var.sql_tcp_port
    protocol        = "tcp"
    prefix_list_ids = var.fci_ingress_prefix_sql
    cidr_blocks     = var.fci_ingress_cidr_sql
  }

  ingress {
    description     = "Allow RDP Connections"
    from_port       = 3389
    to_port         = 3389
    protocol        = "tcp"
    prefix_list_ids = var.fci_ingress_prefix_rdp
    cidr_blocks     = var.fci_ingress_cidr_rdp
  }

  ingress {
    description = "Failover Cluster Service"
    from_port   = 3343
    to_port     = 3343
    protocol    = "tcp"
    cidr_blocks = var.fci_ingress_cidr_clustering
  }

  ingress {
    description = "Failover Cluster Service"
    from_port   = 3343
    to_port     = 3343
    protocol    = "udp"
    cidr_blocks = var.fci_ingress_cidr_clustering
  }

  ingress {
    description = "Failover Cluster RPC"
    from_port   = 135
    to_port     = 135
    protocol    = "tcp"
    cidr_blocks = var.fci_ingress_cidr_clustering
  }

  ingress {
    description = "Failover Cluster Administrator"
    from_port   = 137
    to_port     = 137
    protocol    = "udp"
    cidr_blocks = var.fci_ingress_cidr_clustering
  }

  ingress {
    description = "Failover Cluster Ephemeral"
    from_port   = 1024
    to_port     = 65535
    protocol    = "udp"
    cidr_blocks = var.fci_ingress_cidr_clustering
  }

  ingress {
    description = "Failover Cluster Ephemeral"
    from_port   = 49152
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = var.fci_ingress_cidr_clustering
  }

  ingress {
    description = "Failover Cluster SMB"
    from_port   = 445
    to_port     = 445
    protocol    = "tcp"
    cidr_blocks = var.fci_ingress_cidr_clustering
  }

  ingress {
    description = "Failover Cluster ICMP"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = var.fci_ingress_cidr_clustering
  }

  ingress {
    description = "Failover Health Probe"
    from_port   = var.fci_health_check_port
    to_port     = var.fci_health_check_port
    protocol    = "tcp"
    cidr_blocks = var.fci_ingress_cidr_clustering
  }

  egress {
    description = "Allow All Egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
