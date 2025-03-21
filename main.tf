locals {
  admin_policy_arn   = "arn:aws:iam::aws:policy/AdministratorAccess"
  humanitec_user_arn = "arn:aws:iam::767398028804:user/humanitec"
  tags = {
    Terraform   = "true"
  }
}

resource "humanitec_resource_definition" "tf_runner_config" {
  driver_type = "humanitec/template"
  id = "config-tf-runner"
  name = "config-tf-runner"
  type = "config"
  driver_inputs = {
    values_string = jsonencode({
      templates = {
        outputs = {
          runner = {
            account = "intelerad/ref-arch"
            cluster_type = "eks"
            cluster = {
              "name"                     = "ref-arch"
              "loadbalancer"             = "a802b6e4d6e5e400b987394e91090953-167848583.us-east-1.elb.amazonaws.com"
              "loadbalancer_hosted_zone" = "Z35SXDOTRQ7X7K"
              "region"                   = "us-east-1"
            }
            namespace = "tf-runner-namespace"
            service_account = "tf-runner"

          }
        }
        secrets = jsonencode({
          agent_url = ""
        })
      }
    })
  }
}

resource "humanitec_resource_definition_criteria" "tf_runner_config" {
  resource_definition_id = humanitec_resource_definition.tf_runner_config.id
  env_id = "development"
}

resource "humanitec_resource_definition" "vpc" {
  driver_type = "humanitec/terraform-runner"
  id          = "cpt-poc-vpc"
  name        = "cpt-poc-vpc"
  type        = "base-env"

  driver_account = "ref-arch"

  driver_inputs = {
    values_string = jsonencode({
      source = {
        path = "terraform/vpc"
        rev  = "master"
        url  = "git@github.com:anupclouddevops/humanitec-poc.git"
      }

      variables = {
        identifier            = "anup-humanitec-poc"
        vpc_cidr              = "10.1.0.0/16"
      }

      credentials_config = {
        "environment" = {
          "AWS_ACCESS_KEY_ID"     = "AccessKeyId"
          "AWS_SECRET_ACCESS_KEY" = "SecretAccessKey"
          "AWS_SESSION_TOKEN"     = "SessionToken"
        }
      }
    })

    secret_refs = jsonencode({
      source = {
        ssh_key = {
          store = "iws-dev-secret-store"
          ref = "anup-github-ssh-private-key"
        }
      }
      
    })
  }
}

resource "humanitec_resource_definition_criteria" "vpc" {
  resource_definition_id = humanitec_resource_definition.vpc.id
  env_id = "development"
}


# EC2 Instance
resource "humanitec_resource_definition" "ec2" {
  driver_type = "humanitec/terraform-runner"
  id          = "cpt-poc-ec2"
  name        = "cpt-poc-ec2"
  type        = "base-env"

  driver_account = "ref-arch"

  driver_inputs = {
    values_string = jsonencode({
      source = {
        path = "terraform/ec2"
        rev  = "master"
        url  = "git@github.com:anupclouddevops/humanitec-poc.git"
      }

      variables = {
        subnets = "resources.base-env.default#base-env.outputs.private_subnets"
        vpc_id = "resources.base-env.default#base-env.outputs.vpc_id"
      }
      credentials_config = {
        "environment" = {
          "AWS_ACCESS_KEY_ID"     = "AccessKeyId"
          "AWS_SECRET_ACCESS_KEY" = "SecretAccessKey"
          "AWS_SESSION_TOKEN"     = "SessionToken"
        }
      }
    })

    secret_refs = jsonencode({
      source = {
        ssh_key = {
          store = "iws-dev-secret-store"
          ref = "anup-github-ssh-private-key"
        }
      }
      
    })
  }
}

resource "humanitec_resource_definition_criteria" "ec2" {
  resource_definition_id = humanitec_resource_definition.ec2.id
  env_id = "development"
}

