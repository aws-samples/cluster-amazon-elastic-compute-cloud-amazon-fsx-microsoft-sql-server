data "aws_secretsmanager_secret" "cluster_admin_username" {
  name = var.sqlcluster_username_secret_name
}

data "aws_secretsmanager_secret" "cluster_admin_password" {
  name = var.sqlcluster_password_secret_name
}

data "aws_secretsmanager_secret" "service_admin_username" {
  name = var.sqlservice_username_secret_name
}

data "aws_secretsmanager_secret" "service_admin_password" {
  name = var.sqlservice_password_secret_name
}

data "aws_iam_policy_document" "fci_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_instance_profile" "fci_instance" {
  name = "${var.environment}_${var.cluster_name}_FCI_Instance_Profile"
  role = aws_iam_role.fci_instance_role.name
  tags = local.global_tags
}

resource "aws_iam_role" "fci_instance_role" {
  name               = "${var.environment}_${var.cluster_name}_FCI_Instance_Role"
  tags               = local.global_tags
  assume_role_policy = data.aws_iam_policy_document.fci_assume_role.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]

  inline_policy {
    name = "AllowKMSAccessforVolumes"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["kms:Decrypt"]
          Effect   = "Allow"
          Resource = var.encryption_key_arn
        },
      ]
    })
  }

  inline_policy {
    name = "AllowSecretsManagerAccess"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "secretsmanager:GetSecretValue",
            "secretsmanager:DescribeSecret"
          ]
          Effect = "Allow"
          Resource = [
            data.aws_secretsmanager_secret.cluster_admin_username.arn,
            data.aws_secretsmanager_secret.cluster_admin_password.arn,
            data.aws_secretsmanager_secret.service_admin_username.arn,
            data.aws_secretsmanager_secret.service_admin_password.arn
          ]
        },
      ]
    })
  }

  lifecycle {
    create_before_destroy = true
  }
}
