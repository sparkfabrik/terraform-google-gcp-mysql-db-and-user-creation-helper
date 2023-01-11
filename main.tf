resource "null_resource" "execute_cloud_sql_proxy" {
  for_each = (((var.cloud_sql_proxy_host == "localhost" || var.cloud_sql_proxy_host == "127.0.0.1") && var.terraform_start_cloud_sql_proxy) ? { for u in var.database_setup : u.user => u } : {})
  provisioner "local-exec" {
    command = templatefile(
      "${path.module}/scripts/execute_cloud_sql_proxy.sh",
      {
        CLOUD_SQL_PROXY_HOST   = var.cloud_sql_proxy_host
        CLOUDSDK_CORE_PROJECT  = var.project_id
        CLOUD_SQL_PROXY_PORT   = var.cloud_sql_proxy_port
        GCLOUD_PROJECT_REGION  = var.region
        CLOUDSQL_INSTANCE_NAME = var.google_sql_database_instance_name
      }
    )
    interpreter = [
      "/bin/sh", "-c"
    ]
  }
}

resource "random_password" "sql_user_password" {
  for_each         = { for u in var.database_setup : u.user => u }
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "google_sql_database" "sql_database" {
  project  = var.project_id
  for_each = { for d in var.database_setup : d.database => d }
  name     = each.value.database
  instance = var.google_sql_database_instance_name
}

resource "google_sql_user" "sql_user" {
  project  = var.project_id
  for_each = { for u in var.database_setup : u.user => u }
  instance = var.google_sql_database_instance_name
  name     = each.value.user
  password = random_password.sql_user_password[each.value.user].result
  host     = "%"

  provisioner "local-exec" {
    command = templatefile(
      "${path.module}/scripts/execute_sql.sh",
      {
        CLOUD_SQL_PROXY_HOST   = var.cloud_sql_proxy_host
        SQL_USER_ADMIN         = var.sql_user_admin
        SQL_PASSWORD_ADMIN     = var.sql_password_admin
        mysql_version          = var.mysql_version
        USER                   = each.value.user
        DATABASE               = each.value.database
        CLOUDSDK_CORE_PROJECT  = var.project_id
        CLOUD_SQL_PROXY_PORT   = var.cloud_sql_proxy_port
        GCLOUD_PROJECT_REGION  = var.region
        CLOUDSQL_INSTANCE_NAME = var.google_sql_database_instance_name
      }
    )
    interpreter = [
      "/bin/sh", "-c"
    ]
    when = create
  }
  depends_on = [
    google_sql_database.sql_database
  ]
}

resource "null_resource" "kill_cloud_sql_proxy" {
  for_each = (((var.cloud_sql_proxy_host == "localhost" || var.cloud_sql_proxy_host == "127.0.0.1") && var.terraform_start_cloud_sql_proxy) ? { for u in var.database_setup : u.user => u } : {})
  provisioner "local-exec" {
    command = "${path.module}/scripts/kill_cloud_sql_proxy.sh"
    interpreter = [
      "/bin/sh", "-c"
    ]
    when = create
  }
  depends_on = [
    google_sql_database.sql_database,
    google_sql_user.sql_user
  ]
}
