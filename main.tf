resource "null_resource" "execute_cloud_sql_proxy" {
  for_each = (((var.cloudsql_proxy_host == "localhost" || var.cloudsql_proxy_host == "127.0.0.1") && var.terraform_start_cloud_sql_proxy) ? {
    for u in var.database_and_user_list : u.user => u
  } : {})

  triggers = {
    refresh_id = var.permissions_refresh_id
  }

  lifecycle {
    replace_triggered_by = [
      null_resource.force_permissions_refresh.id
    ]
  }
  provisioner "local-exec" {
    command = "${path.module}/scripts/execute_cloud_sql_proxy.sh"
    environment = {
      CLOUDSDK_CORE_PROJECT  = var.project_id
      CLOUDSQL_PROXY_HOST    = var.cloudsql_proxy_host
      CLOUDSQL_PROXY_PORT    = var.cloudsql_proxy_port
      GCLOUD_PROJECT_REGION  = var.region
      CLOUDSQL_INSTANCE_NAME = var.cloudsql_instance_name
    }
    interpreter = [
      "/bin/sh", "-c"
    ]
  }
}

# Retrieve Cloud SQL instance information (database type) with a data resource.
data "google_sql_database_instance" "cloudsql_instance" {
  name    = var.cloudsql_instance_name
  project = var.project_id

  lifecycle {

    postcondition {
      condition     = startswith(self.database_version, "MYSQL_5_7") || startswith(self.database_version, "MYSQL_8_0") || startswith(self.database_version, "MYSQL_8_4")
      error_message = "Database version must be \"MYSQL_5_7\" or \"MYSQL_8_0\" or \"MYSQL_8_4\". Other versions are not supported."
    }
  }
}

# Generate a random password for each created user.
resource "random_password" "sql_user_password" {
  for_each         = { for u in var.database_and_user_list : u.user => u }
  length           = 16
  special          = true
  override_special = "_~@"
}

# Create the databases.
resource "google_sql_database" "sql_database" {
  project  = var.project_id
  for_each = { for d in var.database_and_user_list : d.database => d }
  name     = each.value.database
  instance = var.cloudsql_instance_name
}

# Create the database users.
resource "google_sql_user" "sql_user" {
  project  = var.project_id
  for_each = { for u in var.database_and_user_list : u.user => u }
  instance = var.cloudsql_instance_name
  name     = each.value.user
  password = random_password.sql_user_password[each.value.user].result
  host     = each.value.user_host
  depends_on = [
    google_sql_database.sql_database
  ]
}

resource "null_resource" "force_permissions_refresh" {
  triggers = {
    refresh_id = var.permissions_refresh_id
  }
}

resource "null_resource" "grant_permissions" {
  for_each = { for u in var.database_and_user_list : u.user => u }

  triggers = {
    user      = each.key
    user_host = each.value.user_host
    database  = each.value.database
  }

  lifecycle {
    replace_triggered_by = [
      null_resource.force_permissions_refresh.id
    ]
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/execute_sql.sh"
    environment = {
      CLOUDSDK_CORE_PROJECT             = var.project_id
      GCLOUD_PROJECT_REGION             = var.region
      CLOUDSQL_INSTANCE_NAME            = var.cloudsql_instance_name
      CLOUDSQL_PROXY_HOST               = var.cloudsql_proxy_host
      CLOUDSQL_PROXY_PORT               = var.cloudsql_proxy_port
      CLOUDSQL_PRIVILEGED_USER_NAME     = var.cloudsql_privileged_user_name
      CLOUDSQL_PRIVILEGED_USER_PASSWORD = var.cloudsql_privileged_user_password
      MYSQL_VERSION                     = data.google_sql_database_instance.cloudsql_instance.database_version
      USER                              = each.value.user
      USER_HOST                         = each.value.user_host
      DATABASE                          = each.value.database
    }
    interpreter = [
      "/bin/sh", "-c"
    ]
  }

  depends_on = [
    google_sql_database.sql_database,
    google_sql_user.sql_user,
    null_resource.execute_cloud_sql_proxy
  ]
}

resource "null_resource" "kill_cloud_sql_proxy" {
  for_each = (((var.cloudsql_proxy_host == "localhost" || var.cloudsql_proxy_host == "127.0.0.1") && var.terraform_start_cloud_sql_proxy) ? {
    for u in var.database_and_user_list : u.user => u
  } : {})

  triggers = {
    refresh_id = var.permissions_refresh_id
  }

  lifecycle {
    replace_triggered_by = [
      null_resource.force_permissions_refresh.id
    ]
  }
  provisioner "local-exec" {
    command = "${path.module}/scripts/kill_cloud_sql_proxy.sh"
    interpreter = [
      "/bin/sh", "-c"
    ]
    when = create
  }
  depends_on = [
    google_sql_database.sql_database,
    google_sql_user.sql_user,
    null_resource.grant_permissions
  ]
}
