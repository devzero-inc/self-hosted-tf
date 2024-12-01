terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.15"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.7.1"
    }
  }
}
