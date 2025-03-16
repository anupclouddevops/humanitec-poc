locals {
  admin_policy_arn   = "arn:aws:iam::aws:policy/AdministratorAccess"
  humanitec_user_arn = "arn:aws:iam::767398028804:user/humanitec"
  tags = {
    Terraform   = "true"
  }
}

resource "random_password" "external_id" {
  length  = 16
  special = false
}

data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [local.humanitec_user_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [random_password.external_id.result]
    }
  }
}

# User for Humanitec to access the EKS cluster
resource "aws_iam_role" "humanitec_svc" {
  name = "humanitec-poc-role"

  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "humanitec_svc" {
  role       = aws_iam_role.humanitec_svc.name
  policy_arn = local.admin_policy_arn
}

resource "humanitec_resource_account" "aws_account" {
  id   = "intelerad-iws-dev"
  name = "intelerad-iws-dev"
  type = "aws-role"

  credentials = jsonencode({
    aws_role    = aws_iam_role.humanitec_svc.arn
    external_id = random_password.external_id.result
  })

  depends_on = [aws_iam_role_policy_attachment.humanitec_svc]
}


resource "humanitec_resource_definition" "vpc" {
  driver_type = "humanitec/terraform"
  id          = "cpt-poc-vpc"
  name        = "cpt-poc-vpc"
  type        = "base-env"

  driver_account = humanitec_resource_account.aws_account.id

  driver_inputs = {
    values_string = jsonencode({
      source = {
        path = "terraform"
        rev  = "master"
        url  = "git@github.com:anupclouddevops/humanitec-poc.git"
      }

      variables = {
        identifier           = "anup-humanitec-poc"
      }
    })

    secrets_string = jsonencode({
      source = {
        ssh_key = file("~/.ssh/id_rsa")
      }
      
    })
  }
}