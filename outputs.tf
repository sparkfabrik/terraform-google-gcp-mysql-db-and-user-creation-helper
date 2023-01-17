output "sql_users_creds" {
  sensitive = true
  description = "The list of the created databases and the relative user username and password. You can use this output to connect to the relative database."
  value = [
    for data in var.database_and_user_list :
    "DATABASE: ${data.database} | USER: ${data.user} | PASSWORD: ${google_sql_user.sql_user[data.user].password}"
  ]
}
