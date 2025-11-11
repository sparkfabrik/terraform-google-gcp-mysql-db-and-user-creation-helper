# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres
to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.5.1] - 2025-11-11

[Compare with previous version](https://github.com/sparkfabrik/terraform-google-gcp-mysql-db-and-user-creation-helper/compare/0.5.0...0.5.1)

### Changed

- Ensure the `execute_cloud_sql_proxy` and `kill_cloud_sql_proxy` null resources pick up `permissions_refresh_id` changes so Terraform always restarts/stops the proxy when permissions are reapplied.
- Enforce the start → grant → stop execution order by wiring the proxy/grant null resources through explicit dependencies.

## [0.5.0] - 2025-11-11

[Compare with previous version](https://github.com/sparkfabrik/terraform-google-gcp-mysql-db-and-user-creation-helper/compare/0.4.1...0.5.0)

### Added

- Introduced the `permissions_refresh_id` input plus the `null_resource.force_permissions_refresh`/`null_resource.grant_permissions` helpers so you can rerun the proxy/grant scripts without recreating users.

### Changed

- Reworked the resource lifecycles so proxy start/kill and permission scripts are re-executed whenever `permissions_refresh_id` changes.
- Hardened the Cloud SQL proxy helper scripts: better logging, explicit dependency checks (mysql/nc/proxy), use of the v2 proxy CLI syntax, and safer shutdown handling.
- Enhanced `execute_sql.sh` so MySQL 8.0/8.4 users have the `cloudsqlsuperuser` role removed, default roles cleared, and only database-scoped privileges granted.
- Documentation updates: clarify Cloud SQL Auth Proxy v2 requirement, mention MySQL 8.4 support.

## [0.4.1] - 2025-02-24

[Compare with previous version](https://github.com/sparkfabrik/terraform-google-gcp-mysql-db-and-user-creation-helper/compare/0.4.0...0.4.1)

- Grant execute permission to execute_cloud_sql_proxy.sh to ensure it can be run as a script.

## [0.4.0] - 2025-01-28

### Changed

- Allow minor versions for MySQL.

## [0.3.2] - 2024-10-30

### Changed

- Fix accidental mysql credential exposure.

## [0.3.1] - 2023-04-14

### Changed

- Changed the output sql_users_creds response.

## [0.3.0] - 2023-01-23

### Changed

- Bump to 0.3, since 0.2.2 was a breaking change.
- User password special characters are now `_~@` from `_%@` to allow masking in Gitlab.

## [0.2.2] - 2023-01-23

### Changed

- The user host is configurable, and not hardcoded to `%`. This allows to
  restrict the access to the database to a specific host. If not specified, it
  will use the default value `%`.

## [0.2.1] - 2023-01-19

### Changed

- Minimum required version of Terraform si 1.2.x

## [0.2.0] - 2023-01-13

### Changed

- Script execution is done through `sh` and not `bash`.
- Added new dependency for filesystem: `netcat`.

## [0.1.0] - 2023-01-12

- Init project.
