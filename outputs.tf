output "fci_cluster_id" {
  description = "The 5 character FCI cluster name used for this SQL installation"
  value       = random_string.cluster_id.result
}

output "sql_endpoint" {
  description = "The endpoint (DNS or IP address) where Port 1433 SQL connections should be sent"
  value       = var.instance_count > 1 ? aws_lb.sql_gateway[0].dns_name : data.aws_network_interface.instance_interfaces[0].private_ips[2]
}
