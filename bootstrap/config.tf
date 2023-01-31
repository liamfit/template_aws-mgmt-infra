terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.51.0"
    }
  }

  backend "local" {
  }
}

provider "aws" {
  region = var.region
}
