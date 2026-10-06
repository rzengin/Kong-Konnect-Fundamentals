terraform {
  required_providers {
    konnect = {
      source  = "kong/konnect"
      version = ">= 3.0.0"
    }
  }
}

provider "konnect" {
  personal_access_token = var.konnect_token
  server_url            = var.konnect_addr
}
