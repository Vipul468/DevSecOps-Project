terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.40"
    }
  }

  # OPTIONAL remote state — create the bucket + DynamoDB table first, then uncomment.
  # backend "s3" {
  #   bucket         = "my-tf-state-prime-clone"
  #   key            = "devops-project2/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "tf-locks"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.region
}
