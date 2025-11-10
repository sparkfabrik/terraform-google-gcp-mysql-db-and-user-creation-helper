database_and_user_list = [
  {
    database = "db1"
    user     = "user1"
  },
  {
    database = "db2"
    user     = "user2"
  },
  {
    database = "db3"
    user     = "user3"
  },
  {
    database  = "db4"
    user_host = "cloudsqlproxy~%"
    user      = "user4"
  }
]

# Bump this value (YYYYMMDD, e.g. 20251110) whenever you need to rerun the proxy/grant scripts without recreating users.
permissions_refresh_id = "20251110"
