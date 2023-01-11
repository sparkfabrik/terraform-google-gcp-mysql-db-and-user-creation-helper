variable "google_sql_database_instance_name" {
  type        = string
  description = "Google SQL Instance name"
}

variable "cloud_sql_proxy_host" {
  type        = string
  description = "Host Cloud SQL Auth Proxy, if a host other than `localhost` or `127.0.0.1` is set it will be disabled to start Cloud SQL Proxy on the local machine"
  default     = "127.0.0.1"
}

variable "database_setup" {
  type = list(object({
    user     = string
    database = string
  }))
  description = "Map User and database"
}

variable "sql_user_admin" {
  type        = string
  description = "SQL User Admin"
  default     = "admin"
}

variable "sql_password_admin" {
  type        = string
  description = "SQL Password Admin"
}

variable "cloud_sql_proxy_port" {
  type        = string
  description = "Port Google SQL Instance"
  default     = "1234"
}

variable "mysql_version" {
  type        = string
  description = "The version of mysql: `MYSQL_5_7`, `MYSQL_8_0`"
  validation {
    condition     = var.mysql_version == "MYSQL_5_7" || var.mysql_version == "MYSQL_8_0"
    error_message = "Specify the version of mysql: `MYSQL_5_7` or `MYSQL_8_0`."
  }
}

variable "project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "region" {
  type        = string
  description = "GCP Region"
}

variable "terraform_start_cloud_sql_proxy" {
  type        = bool
  default     = true
  description = "If `true` terraform will automatically start the Cloud SQL Proxy instance present in the filesystem"
}
