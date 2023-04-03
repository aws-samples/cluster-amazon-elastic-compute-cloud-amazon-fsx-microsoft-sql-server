resource "random_password" "sa_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]<>:?"
}

resource "aws_secretsmanager_secret" "sa_password" {
  name       = "${var.environment}/sqlserver/${var.cluster_name}/sa_password"
  kms_key_id = var.encryption_key_id
  tags       = local.global_tags
}

resource "aws_secretsmanager_secret_version" "sa_password" {
  secret_id     = aws_secretsmanager_secret.sa_password.id
  secret_string = random_password.sa_password.result
}
