terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.2.0"

  backend "s3" {
    bucket = "luism-tf-states"          # Bucket S3 para estado remoto de Terraform
    key    = "serverless-app/terraform.tfstate"  
    region = "us-east-2"
    encrypt      = true
  }
}

provider "aws" {
  region = "us-east-2"
}
