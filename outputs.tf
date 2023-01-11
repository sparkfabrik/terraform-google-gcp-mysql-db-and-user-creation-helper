output "sql_users_password" {
  sensitive = true
  value = {
    for k, userp in google_sql_user.sql_user : k => userp.password
  }
}
