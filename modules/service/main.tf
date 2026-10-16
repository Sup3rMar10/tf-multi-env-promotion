terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

variable "env" {
  type = string
}

variable "replicas" {
  type = number

  validation {
    condition     = var.replicas >= 1
    error_message = "replicas must be at least 1."
  }

  # A guard that lives with the module, so no environment can bypass it.
  validation {
    condition     = var.env != "prod" || var.replicas >= 2
    error_message = "prod must run at least 2 replicas."
  }
}

variable "log_level" {
  type    = string
  default = "info"
}

resource "local_file" "service" {
  filename = "${path.root}/out/service-${var.env}.json"
  content = jsonencode({
    env       = var.env
    replicas  = var.replicas
    log_level = var.log_level
  })
}
