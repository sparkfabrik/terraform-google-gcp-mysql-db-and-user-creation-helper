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

variable "permissions_refresh_id" {
  type        = string
  default     = ""
  description = "Change this date or date-time (YYYYMMDD or YYYYMMDDHHMM, e.g. 20251110 or 202511101030) to force rerunning the proxy/grant scripts."
}
