variable "project" {
  type = string
  description = "Project name"
}

variable "environment" {
  type = string
  description = "Environment (dev / stage / prod)"
}

variable "location" {
  type = string
  description = "Azure region"
}

variable "apim_auth_server_name" {
  type = string
  description = "APIM Auth server name"
  default = "test-auth-server"
}