# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v8.4.0] - 2020-10-06
### Removed
- Cluster master username, password
### Added
- Cluster master auth token

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
### Add
- Add provisioning of compute instances from ssh provisioners to user-data metadata
### Fix
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
