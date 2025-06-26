terraform {
  required_version = ">= 1.3.0"

  backend "s3" {
    bucket         = "mi-bucket-terraform-lily-2"    # Bucket creado manualmente
    key            = "facturapi-demo/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-locks"        # Tabla creada manualmente
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
