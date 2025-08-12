terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60"
    }
  }

  backend "s3" {
    bucket         = "demo-devops-tfstate-924842505079-us-east-1"
    key            = "infra/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "demo-devops-tf-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.region   # keep var.region = "us-east-1"
}
