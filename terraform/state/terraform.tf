terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
    kubernetes = {
      version = "~> 2.0"
    }
  }
  backend "s3" {
    bucket         = "tsh-eks-demo-terraform-state"
    key            = "state/terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
    kms_key_id     = "alias/terraform_bucket_key"
    dynamodb_table = "tsh-eks-demo-terraform-state"
  }
  required_version = ">= 1.3"
}

provider "aws" {
  region = "eu-west-1"

  default_tags {
    tags = {
      "managed_by" = "terraform"
      "source"     = "https://github.com/TheSoftwareHouse/eks-demo"
      "owner"      = "The Software House"
    }
  }
}
