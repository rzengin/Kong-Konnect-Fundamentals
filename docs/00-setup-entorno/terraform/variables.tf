variable "konnect_token" {
  type        = string
  description = "Kong Konnect Personal Access Token (PAT)"
  sensitive   = true
}

variable "konnect_addr" {
  type        = string
  description = "Kong Konnect API Address"
  default     = "https://us.api.konghq.com"
}

variable "demo_prefix" {
  type        = string
  description = "Prefijo único para el participante (ej. juanperez, user01)"
}
