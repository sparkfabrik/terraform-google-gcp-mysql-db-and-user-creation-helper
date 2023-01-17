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
  description = "The name of the existing Google CloudSQL Instance name. Actually only a MySQL 5.7 or 8 instance is supported."
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

variable "database_and_user_list" {
  type = list(object({
    user     = string
    database = string
  }))
  description = "The list with all the databases and the relative user. Please not that you can assign only a database to a single user, the same user cannot be assigned to multiple databases."
}

