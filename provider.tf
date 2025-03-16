terraform {
  required_providers {
    humanitec = {
      source  = "humanitec/humanitec"
      version = "~> 1.7.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.91.0"
    }
  }
  required_version = ">= 1.3.0"
}

provider "humanitec" {
  org_id = var.humanitec_org_id
}

provider "aws" {
  region = "us-east-1"
}