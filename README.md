# Terraform module for creating database and associated user on an existing Google CloudSQL instance

This module creates database and users on an existing CloudSQL instance. The structure of the input variable is designed so that the database/user ratio is 1:1, so the module not only takes care of creating the database and its user, but also sets permissions on the user so that it has access to only the database for which it is responsible.

To enforce permissions, the module executes SQL commands with the mysql cli, which is therefore a prerequisite (it must be present in the filesystem where terraform apply is executed).

In addition, the script must be able to connect to the CloudSQL instance. In case this is not easily accessible from the terraform cli, the module is able to:

1. Start an instance of [CloudSQL Auth Proxy](https://cloud.google.com/sql/docs/mysql/sql-proxy), for this purpose two null resources will be created for each user added to the database, enabling this option requires the [presence of the proxy executable](https://cloud.google.com/sql/docs/mysql/sql-proxy) in the filesystem where `terraform apply` is executed.
2. Connect from a [CloudSQL Auth Proxy](https://cloud.google.com/sql/docs/mysql/sql-proxy) instance not present in the filesystem.

### IMPORTANT

CloudSQL Auth Proxy needs the CloudSQL instance to expose a public IP address in order to connect to the instance itself.

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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.2 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.47.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.2.1 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.4.3 |
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudsql_instance_name"></a> [cloudsql\_instance\_name](#input\_cloudsql\_instance\_name) | The name of the existing Google CloudSQL Instance name. Actually only a MySQL 5.7 or 8 instance is supported. | `string` | n/a | yes |
| <a name="input_cloudsql_privileged_user_name"></a> [cloudsql\_privileged\_user\_name](#input\_cloudsql\_privileged\_user\_name) | The name of the privileged user of the Cloud SQL instance | `string` | n/a | yes |
| <a name="input_cloudsql_privileged_user_password"></a> [cloudsql\_privileged\_user\_password](#input\_cloudsql\_privileged\_user\_password) | The password of the privileged user of the Cloud SQL instance | `string` | n/a | yes |
| <a name="input_cloudsql_proxy_host"></a> [cloudsql\_proxy\_host](#input\_cloudsql\_proxy\_host) | The host of the Cloud SQL Auth Proxy; if a value other than localhost or 127.0.0.1 (default) is entered, it is assumed that there is a CloudSQL Auth Proxy instance defined and already configured outside this module, and therefore the proxy will not be launched. | `string` | `"127.0.0.1"` | no |
| <a name="input_cloudsql_proxy_port"></a> [cloudsql\_proxy\_port](#input\_cloudsql\_proxy\_port) | Port of the Cloud SQL Auth Proxy | `string` | `"1234"` | no |
| <a name="input_database_and_user_list"></a> [database\_and\_user\_list](#input\_database\_and\_user\_list) | The list with all the databases and the relative user. Please not that you can assign only a database to a single user, the same user cannot be assigned to multiple databases. `user_host` is optional, has a default value of '%' to allow the user to connect from any host, or you can specify it for the given user for a more restrictive access. | <pre>list(object({<br>    user      = string<br>    user_host = optional(string, "%")<br>    database  = string<br>  }))</pre> | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the project in which the resource belongs. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region in which the resource belongs. | `string` | n/a | yes |
| <a name="input_terraform_start_cloud_sql_proxy"></a> [terraform\_start\_cloud\_sql\_proxy](#input\_terraform\_start\_cloud\_sql\_proxy) | If `true` terraform will automatically start the Cloud SQL Proxy instance present in the filesystem at the condition that cloudsql\_proxy\_host is set to a supported value. If `false` you have to start the Cloud SQL Proxy manually. This variable is used to prevent the creation of a Cloud SQL Proxy instance even if cloudsql\_proxy\_host has a supported value. | `bool` | `true` | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_sql_users_creds"></a> [sql\_users\_creds](#output\_sql\_users\_creds) | The list of the created databases and the relative user username and password. You can use this output to connect to the relative database. |
## Resources

| Name | Type |
|------|------|
| [google_sql_database.sql_database](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database) | resource |
| [google_sql_user.sql_user](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_user) | resource |
| [null_resource.execute_cloud_sql_proxy](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.kill_cloud_sql_proxy](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_password.sql_user_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [google_sql_database_instance.cloudsql_instance](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/sql_database_instance) | data source |
## Modules

No modules.

<!-- END_TF_DOCS -->
