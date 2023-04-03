resource "aws_lb" "sql_gateway" {
  count                      = var.instance_count > 1 ? 1 : 0
  name                       = "sql-${var.environment}-${var.cluster_name}"
  internal                   = true
  load_balancer_type         = "network"
  subnets                    = var.instance_subnet_map
  enable_deletion_protection = var.enable_termination_protection

  tags = merge(local.global_tags, {
    Name = format("%s.%s.%s.%s", "emcloud", var.environment, "sqlgateway", upper(var.cluster_name))
  })
}

resource "aws_lb_listener" "sql" {
  count             = var.instance_count > 1 ? 1 : 0
  load_balancer_arn = aws_lb.sql_gateway[0].arn
  port              = tostring(var.sql_tcp_port)
  protocol          = "TCP"
  tags              = local.global_tags

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.fci_instances[0].arn
  }
}

resource "aws_lb_target_group" "fci_instances" {
  count                = var.instance_count > 1 ? 1 : 0
  name                 = "sql-${var.environment}-${var.cluster_name}-tg"
  protocol             = "TCP"
  port                 = var.sql_tcp_port
  vpc_id               = var.vpc_id
  target_type          = "ip"
  deregistration_delay = 10
  preserve_client_ip   = true

  health_check {
    enabled             = true
    interval            = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
    port                = var.fci_health_check_port
    protocol            = "TCP"
  }

  tags = merge(local.global_tags, {
    Name = format("%s.%s.%s.%s", "emcloud", var.environment, "sqltargetgroup", upper(var.cluster_name))
  })
}

resource "aws_lb_target_group_attachment" "fci_instance" {
  count            = var.instance_count > 1 ? var.instance_count : 0
  target_group_arn = aws_lb_target_group.fci_instances[0].arn
  target_id        = data.aws_network_interface.instance_interfaces[count.index].private_ips[2]
  port             = var.sql_tcp_port
}

resource "aws_secretsmanager_secret" "sql_endpoint" {
  name       = "${var.environment}/sqlserver/${var.cluster_name}/endpoint"
  kms_key_id = var.encryption_key_id
  tags       = local.global_tags
}

resource "aws_secretsmanager_secret_version" "sql_endpoint" {
  secret_id     = aws_secretsmanager_secret.sql_endpoint.id
  secret_string = var.instance_count > 1 ? aws_lb.sql_gateway[0].dns_name : data.aws_network_interface.instance_interfaces[0].private_ips[2]
}
