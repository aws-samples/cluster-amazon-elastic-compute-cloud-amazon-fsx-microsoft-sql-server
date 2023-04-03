resource "tls_private_key" "fci" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "fci_instance" {
  key_name   = "${var.environment}_${var.cluster_name}_FCIKeyPair"
  public_key = tls_private_key.fci.public_key_openssh

  tags = merge(local.global_tags, {
    "Name" = "${var.environment}_${var.cluster_name}_FCIKeyPair",
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_secretsmanager_secret" "keypair" {
  name       = "${var.environment}/sqlserver/${var.cluster_name}/keypair"
  kms_key_id = var.encryption_key_id
  tags       = local.global_tags
}

resource "aws_secretsmanager_secret_version" "keypair" {
  secret_id     = aws_secretsmanager_secret.keypair.id
  secret_string = tls_private_key.fci.private_key_pem
}
