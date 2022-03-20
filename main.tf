terraform {
    required_version = ">= 0.13"
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 3.0"
        }
    }
    backend "s3" {
        bucket = "tastylog-tfstate-bucket-321120513547"
        key = "tastylog-dev.tfstate"
        region = "ap-northeast-1"
        profile = "terraform"
    }
}

provider "aws" {
    profile = "terraform"
    region = "ap-northeast-1"
}

variable "project" {
    type = string
}

variable "environment" {
    type = string
}