resource "google_compute_network" "private_network" {
  provider = google
  project  = var.project_id
  name     = "private-network"
}

resource "google_compute_global_address" "private_ip_address" {
  provider      = google
  project       = var.project_id
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.private_network.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  provider = google

  network = google_compute_network.private_network.id
  service = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [
    google_compute_global_address.private_ip_address.name
  ]
}

resource "random_id" "db_name_suffix" {
  byte_length = 4
}

# Create a CloudSQL MySQL 8 instance
resource "google_sql_database_instance" "instance" {
  provider            = google
  project             = var.project_id
  name                = "private-instance-${random_id.db_name_suffix.hex}"
  region              = var.region
  database_version    = "MYSQL_8_0"
  deletion_protection = false
  depends_on = [
    google_service_networking_connection.private_vpc_connection
  ]

  settings {
    disk_size = 10
    tier      = "db-f1-micro"
    backup_configuration {
      enabled = false
    }
    ip_configuration {
      ipv4_enabled    = true
      private_network = google_compute_network.private_network.id
    }
  }
}

# Create admin credentials for MySQL.
resource "random_password" "admin_sql_user_password_mysql" {
  length           = 24
  special          = true
  override_special = "_~@"
}

resource "google_sql_user" "admin_user_mysql" {
  project  = var.project_id
  instance = google_sql_database_instance.instance.name
  name     = "admin"
  password = random_password.admin_sql_user_password_mysql.result
  host     = "%"
}

# Add additional user and database using this this module.
module "mysql_additional_users_and_databases" {
  source                            = "sparkfabrik/gcp-mysql-db-and-user-creation-helper/sparkfabrik"
  version                           = "~> 0.1"
  project_id                        = var.project_id
  region                            = var.region
  database_and_user_list            = var.database_and_user_list
  cloudsql_instance_name            = google_sql_database_instance.instance.name
  cloudsql_privileged_user_name     = google_sql_user.admin_user_mysql.name
  cloudsql_privileged_user_password = google_sql_user.admin_user_mysql.password
}
