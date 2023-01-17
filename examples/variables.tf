variable "project_id" {
  type    = string
  default = "my-project"
}

variable "region" {
  type    = string
  default = "europe-west1"
}

variable "zone" {
  type    = string
  default = "europe-west1-b"
}

variable "database_and_user_list" {
  type = list(object({
    user     = string
    database = string
  }))
}
