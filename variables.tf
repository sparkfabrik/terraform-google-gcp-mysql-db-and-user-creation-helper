variable "project_id" {
  type        = string
  description = "The ID of the project in which the resource belongs."
}

variable "region" {
  type        = string
  description = "The region in which the resource belongs."
}

variable "cloudsql_instance_name" {
  type        = string
  description = "The name of the existing Google CloudSQL Instance name. MySQL 5.7, 8.0 and 8.4 are supported."
}

variable "terraform_start_cloud_sql_proxy" {
  type        = bool
  description = "If `true` terraform will automatically start the Cloud SQL Proxy instance present in the filesystem at the condition that cloudsql_proxy_host is set to a supported value. If `false` you have to start the Cloud SQL Proxy manually. This variable is used to prevent the creation of a Cloud SQL Proxy instance even if cloudsql_proxy_host has a supported value."
  default     = true
}

variable "cloudsql_proxy_host" {
  type        = string
  description = "The host of the Cloud SQL Auth Proxy; if a value other than localhost or 127.0.0.1 (default) is entered, it is assumed that there is a CloudSQL Auth Proxy instance defined and already configured outside this module, and therefore the proxy will not be launched."
  default     = "127.0.0.1"
}

variable "cloudsql_proxy_port" {
  type        = string
  description = "Port of the Cloud SQL Auth Proxy"
  default     = "1234"
}

variable "cloudsql_privileged_user_name" {
  type        = string
  description = "The name of the privileged user of the Cloud SQL instance"
}

variable "cloudsql_privileged_user_password" {
  type        = string
  description = "The password of the privileged user of the Cloud SQL instance"
}

# Optional value: refs https://developer.hashicorp.com/terraform/language/expressions/type-constraints#optional-object-type-attributes
variable "database_and_user_list" {
  type = list(object({
    user      = string
    user_host = optional(string, "%")
    database  = string
  }))
  description = "The list with all the databases and the relative user. Please note that you can assign only a database to a single user, the same user cannot be assigned to multiple databases. `user_host` is optional, has a default value of '%' to allow the user to connect from any host, or you can specify it for the given user for a more restrictive access."
}

variable "permissions_refresh_id" {
  type        = string
  default     = ""
  description = "Optional identifier (use format YYYYMMDD or YYYYMMDDHHMM, e.g. 20251110 or 202511101030) used only to force Terraform to rerun the proxy/grant scripts without recreating users. Change the value whenever you need to reapply permissions."

  validation {
    condition     = var.permissions_refresh_id == "" || can(regex("^\\d{8}(\\d{4})?$", var.permissions_refresh_id))
    error_message = "Set permissions_refresh_id to an 8-digit date (YYYYMMDD) or a 12-digit date-time (YYYYMMDDHHMM) such as 20251110 or 202511101030, or leave it empty."
  }
}
