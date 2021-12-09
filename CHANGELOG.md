# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v12.0.0] - 2021-12-13
### Added
 - Instance labels, they are added to Cloud Ops Agent metrics metadata as `metadata.user_labels.*` array
### Removed
 - Fluentd config, as Fluentd was part of the removed Google Cloud metrics agent, please use v1.0.0 of the 
[packer-elasticsearch](https://github.com/AckeeCZ/packer-elasticsearch)

## [v11.1.0] - 2021-11-29
### Added
 - parameter `custom_pre_start_commands` allowing to run commands before running Elasticsearch

## [v11.0.0] - 2021-11-10
### Changed
 - Updated minimum TF version to 1.0
 - Updated TF provider version in example to latest versions
 - Convert provider lockings in example to TF0.15+ format

## [v10.0.1] - 2021-08-25
### Fixed
- Fix default value for `health_check_interval_sec` var, it has to be greater or equal to `health_check_timeout_sec`
### Added
- Add terraform lifecycle metatag `create_before_destroy = true`, so we can replace existing HealthCheck resource seamlessly

## [v10.0.0] - 2021-08-23
### Changed
- Change `google_compute_health_check` from `TCP` to `HTTP`
### Added 
- Add `health_check_healthy_threshold` var, default set to `2` 
- Add `health_check_unhealthy_threshold` var, default set to `2` 

## [v9.6.0] - 2021-07-23
### Added
- Add variables for health check management
- Add `backend_service_timeout_sec` to customize backend timeout

## [v9.5.0] - 2021-07-22
### Added
- Add `enable_health_check_logging` to enable logging of health checks if needed

## [v9.4.0] - 2021-05-18
### Added
- Parameterize hardcoded variables

## [v9.3.0] - 2021-04-19
### Changed
- Remove `load_config_file` parameter from `kubernetes` provider - this allows their upgrade to version 2
- Bump `kubernetes` provider version in example

## [v9.2.0] - 2021-02-15
### Changed
- Change README usage description

## [v9.1.0] - 2021-02-15
### Added
- Add custom commands to add customization to bootstrap script

## [v9.0.1] - 2021-02-14
### Fixed 
- kubernetes provider access token parameter name is `token`

## [v9.0.0] - 2021-02-09
### Removed	
 - Cluster master username, password	
### Added	
 - Cluster master auth token

## [v8.6.0] - 2021-02-08
### Added
- Add creation of backup repository if it does not already exist
- Create snapshot lifecycle management policy named "nightly-backups" that backup cluster every night
- Add Kubernetes cronjob with snapshot repository cleanup

## [v8.5.1] - 2021-01-11
### Fixed
- Fix missing value for root disk size, add 10GB as default

## [v8.5.0] - 2021-01-09
### Added
- Add variable for root disk size

## [v8.4.1] - 2021-01-07
### Fixed
- Local variable `master_list` did not included random name suffix, which resulted in non-existing hostnames for bootstrap

## [v8.4.0] - 2020-10-02
### Added
- Add Fluentd configuration for Elasticsearch cluster log file

## [v8.3.0] - 2020-09-18
### Added
- Add all used providers locks to `example/main.tf`
### Removed
- Provider locks in module
### Changed
- Bumped GKE module in example to version without provider locks
- `example/terraform_backend.sh` renamed to `example/spinup_testing.sh` that we use in other modules 

## [v8.2.0] - 2020-07-31
### Added
- Add variable allowing different machine types

## [v8.1.0] - 2020-07-23
### Added
- Add optional (turned on by `add_random_suffix` parameter) random suffix to all resources that will prevent more instances of this module to be provisioned

## [v8.0.0] - 2020-07-22
### Changed
- Changed internal load-balancer from internal-managed to TCP internal
### Removed
- Public IP addresses from the cluster nodes
### Added
- Add provisioning of compute instances from ssh provisioners to user-data metadata
### Fixed
- Elasticsearch's `network.host` configuration directive to enable TCP internal load-balancer traffic and health checks

## [v7.0.0] - 2020-06-23
### Changed
- Changed internal load-balancer handling, now it's created in terraform based in un-managed instance groups 
- Add k8s resources to support `goproxie`

## [v6.1.0] - 2020-05-04
### Changed
- Upgrade Google GA provider lock to `~> 3.19.0`, remove `google-beta` provider as all needed versions are now in GA.

## [v6.0.0] - 2020-04-07
### Added
- Add automatic documentation
- Add k8s endpoints and services
- Add CHANGELOG.md
- Add tf example
