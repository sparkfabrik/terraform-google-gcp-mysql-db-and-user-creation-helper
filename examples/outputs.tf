output "sql_users_password" {
  sensitive = true
  value     = module.mysql_create_users_and_databases.sql_users_password
}

output "sql_user_admin_password" {
  sensitive = true
  value     = google_sql_user.admin_user_mysql.password
}
