terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = "~> 1.0"
}

provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key
  token      = var.session_token

  default_tags {
    tags = {
      "Owner"                          = "zackbradys"
      "KeepRunning"                    = "true"
      "provisioner"                    = "terraform"
    }
  }
}
