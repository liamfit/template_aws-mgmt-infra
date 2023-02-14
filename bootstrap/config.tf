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

provider "aws" {
  region  = var.region
  profile = "dev"
  alias   = "dev"
}

provider "aws" {
  region  = var.region
  profile = "test"
  alias   = "test"
}

provider "aws" {
  region  = var.region
  profile = "prod"
  alias   = "prod"
}
