# Terraform module for creating database and associated user on an existing CloudSQL instance

This module creates database and users on an existing CloudSQL instance. The structure of the input variable is designed so that the database/user ratio is 1:1, so the module not only takes care of creating the database and its user, but also sets permissions on the user so that he or it has access to only the database for which he or she is responsible.

To enforce permissions, the module executes SQL commands with the mysql cli, which is therefore a prerequisite (it must be present in the filesystem where terraform apply is executed).

In addition, the script must be able to connect to the CloudSQL instance. In case this is not easily accessible from the terraform cli, the module is able to:

1. Start an instance of [CloudSQL Auth Proxy](https://cloud.google.com/sql/docs/mysql/sql-proxy), for this purpose two null resources will be created for each user added to the database, enabling this option requires the [presence of the proxy executable](https://cloud.google.com/sql/docs/mysql/sql-proxy) in the filesystem where `terraform apply` is executed.
2. Connect from a [CloudSQL Auth Proxy](https://cloud.google.com/sql/docs/mysql/sql-proxy) instance not present in the filesystem.

<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 4.47.0 |
| <a name="provider_null"></a> [null](#provider\_null) | >= 3.2.1 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.4.3 |
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.47.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.2.1 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.4.3 |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_sql_proxy_host"></a> [cloud\_sql\_proxy\_host](#input\_cloud\_sql\_proxy\_host) | Host Cloud SQL Auth Proxy, if a host other than `localhost` or `127.0.0.1` is set it will be disabled to start Cloud SQL Proxy on the local machine | `string` | `"127.0.0.1"` | no |
| <a name="input_cloud_sql_proxy_port"></a> [cloud\_sql\_proxy\_port](#input\_cloud\_sql\_proxy\_port) | Port Google SQL Instance | `string` | `"1234"` | no |
| <a name="input_database_setup"></a> [database\_setup](#input\_database\_setup) | Map User and database | <pre>list(object({<br>    user     = string<br>    database = string<br>  }))</pre> | n/a | yes |
| <a name="input_google_sql_database_instance_name"></a> [google\_sql\_database\_instance\_name](#input\_google\_sql\_database\_instance\_name) | Google SQL Instance name | `string` | n/a | yes |
| <a name="input_mysql_version"></a> [mysql\_version](#input\_mysql\_version) | The version of mysql: `MYSQL_5_7`, `MYSQL_8_0` | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | GCP Project ID | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | GCP Region | `string` | n/a | yes |
| <a name="input_sql_password_admin"></a> [sql\_password\_admin](#input\_sql\_password\_admin) | SQL Password Admin | `string` | n/a | yes |
| <a name="input_sql_user_admin"></a> [sql\_user\_admin](#input\_sql\_user\_admin) | SQL User Admin | `string` | `"admin"` | no |
| <a name="input_terraform_start_cloud_sql_proxy"></a> [terraform\_start\_cloud\_sql\_proxy](#input\_terraform\_start\_cloud\_sql\_proxy) | If `true` terraform will automatically start the Cloud SQL Proxy instance present in the filesystem | `bool` | `true` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_sql_users_password"></a> [sql\_users\_password](#output\_sql\_users\_password) | n/a |
## Resources

| Name | Type |
|------|------|
| [google_sql_database.sql_database](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database) | resource |
| [google_sql_user.sql_user](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_user) | resource |
| [null_resource.execute_cloud_sql_proxy](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.kill_cloud_sql_proxy](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_password.sql_user_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
## Modules

No modules.

<!-- END_TF_DOCS -->
