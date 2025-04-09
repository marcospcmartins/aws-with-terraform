terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.12.0"
    }
  }

  required_version = ">= 1.10.5"

  backend "s3" {
    bucket = "services-tfstate"
    key    = "infrastructure/terraform.tfstate"
    region = "us-east-1"
  }
}
