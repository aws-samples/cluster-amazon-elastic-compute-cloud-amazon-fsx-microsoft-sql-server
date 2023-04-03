locals {
  fsx_subnets = var.deployment_type == "SINGLE_AZ_2" ? toset([data.aws_subnets.selected.ids[0]]) : toset(flatten([data.aws_subnets.selected.ids]))
  tcp_ports   = [135, 445, 636, 5985, 9389, 53, 88, 389, 464]
  udp_ports   = [53, 123, 88, 389, 464]
  all_ports = {
    3268 = {
      protocol  = "tcp"
      from_port = 3268
      to_port   = 3269
    }
    ephimeral = {
      protocol  = "tcp"
      from_port = 49152
      to_port   = 65535
    }
  }
}

# Fetch subnets
data "aws_subnets" "selected" {
  filter {
    name   = "tag:Name"
    values = [var.fsx_attach_subnet_filter]
  }
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

# FSx for windows (AWS Managed Microsoft Active Directory)
resource "aws_fsx_windows_file_system" "example" {
  active_directory_id = var.active_directory_id
  kms_key_id          = var.fsx_kms_key
  storage_capacity    = var.storage_capacity
  storage_type        = var.storage_type
  subnet_ids          = local.fsx_subnets
  throughput_capacity = var.throughput_capacity
  security_group_ids  = [aws_security_group.fsx_sg.id]
  deployment_type     = var.deployment_type
  preferred_subnet_id = var.preferred_subnet_id != "" ? var.preferred_subnet_id : data.aws_subnets.selected.ids[0]

  tags = merge(
    {
      "Name" = var.fsx_name
    },
    local.common_tags
  )

  timeouts {
    create = "1h"
    delete = "1h"
  }
}

# FSx Security Group
resource "aws_security_group" "fsx_sg" {
  name        = "${var.fsx_name}-sg"
  description = "FSx access"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = length(var.fsx_ingress_prefix_ids) > 0 ? [true] : []
    content {
      description     = "smb connections"
      from_port       = 445
      to_port         = 445
      protocol        = "tcp"
      prefix_list_ids = var.fsx_ingress_prefix_ids
    }
  }
  dynamic "ingress" {
    for_each = toset(local.tcp_ports)
    content {
      description = "description ${ingress.key}"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = var.fsx_ingress_cidr_blocks
    }
  }
  dynamic "ingress" {
    for_each = toset(local.udp_ports)
    content {
      description = "description ${ingress.key}"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "udp"
      cidr_blocks = var.fsx_ingress_cidr_blocks
    }
  }
  dynamic "ingress" {
    for_each = local.all_ports
    content {
      description = "description ${ingress.key}"
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = var.fsx_ingress_cidr_blocks
    }
  }
  tags = merge(
    local.common_tags,
    {
      Name = "${var.fsx_name}-sg"
    },
  )
}

resource "aws_security_group_rule" "egress" {
  security_group_id = aws_security_group.fsx_sg.id
  type              = "egress"
  description       = "Public Internet"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}
