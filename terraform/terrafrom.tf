terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "s3"{
    bucket = "terrafrom-vilayil"
    key = "producction/terraform.tfstate"
    region = "ap-south-1"
  }
}