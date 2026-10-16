terraform {
  required_version = ">= 1.9"
}

module "service" {
  source    = "../../modules/service"
  env       = "stage"
  replicas  = 2
  log_level = "info"
}
