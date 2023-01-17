terraform {
  required_version = "~> 1.0"
  backend "http" {
  }
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = ">= 3"
    }

    google = {
      source  = "hashicorp/google"
      version = "4.47.0"

    }

    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
  }
}

provider "google" {
  region = var.region
  zone   = var.zone
}
