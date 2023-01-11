variable "project_id" {
  type    = string
  default = "sf-platform-gka-playground"
}

variable "region" {
  type    = string
  default = "europe-west1"
}

variable "zone" {
  type    = string
  default = "europe-west1-b"
}

variable "database_setup" {
  type = list(object({
    user     = string
    database = string
  }))
}
