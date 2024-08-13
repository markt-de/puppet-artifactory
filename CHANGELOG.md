# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [v4.0.0] - 2024-08-13

### Added
* Add support for new installation method 'archive'
* Add support for Debian repository ([#FV24])
* Add support for S3 binary store ([#FV25])
* Enable GitHub Actions

### Changed
* Remove default value for parameter `$package_version`
* Move default values to module data (Hiera)
* Move hardcoded YUM gpgkey to Hiera
* Update OS support and dependencies
* Convert documentation to Puppet Strings
* Update to PDK 3.2.0
* Update documentation
* Migrate unit tests to artifactory v7

### Fixed
* Revive unit and acceptance tests
* Fix puppet-lint/rubocop offenses

### Removed
* Remove support for setting up a MySQL server instance
* Remove dependency: puppetlabs/mysql

[Unreleased]: https://github.com/markt-de/puppet-artifactory/compare/v4.0.0...HEAD
[v4.0.0]: https://github.com/markt-de/puppet-artifactory/compare/v3.0.5...v4.0.0
[#1]: https://github.com/markt-de/puppet-artifactory/pull/1
[#FV25]: https://github.com/fervidus/artifactory/pull/25
[#FV24]: https://github.com/fervidus/artifactory/pull/24
