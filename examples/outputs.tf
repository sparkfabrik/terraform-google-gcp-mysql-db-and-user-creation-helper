output "sql_admin_user_creds" {
  sensitive = true
  value     = {
    admin = google_sql_user.admin_user_mysql.password
  }
}

output "sql_additional_users_credentials" {
  sensitive = true
  value     = module.mysql_additional_users_and_databases.sql_users_creds
}
