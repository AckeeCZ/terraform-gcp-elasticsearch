# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
