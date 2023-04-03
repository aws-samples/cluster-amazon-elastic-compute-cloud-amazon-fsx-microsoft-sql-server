output "fsx_name" {
  description = "fsx dns name"
  value       = aws_fsx_windows_file_system.example.dns_name
}

output "remote_admin_endpoint" {
  description = "management endpoint"
  value       = aws_fsx_windows_file_system.example.remote_administration_endpoint
}
