# puppet-artifactory

[![Build Status](https://github.com/markt-de/puppet-artifactory/actions/workflows/ci.yaml/badge.svg)](https://github.com/markt-de/puppet-artifactory/actions/workflows/ci.yaml)
[![Puppet Forge](https://img.shields.io/puppetforge/v/markt/artifactory.svg)](https://forge.puppetlabs.com/markt/artifactory)
[![Puppet Forge - downloads](https://img.shields.io/puppetforge/dt/markt/artifactory.svg)](https://forge.puppetlabs.com/markt/artifactory)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with artifactory](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with artifactory](#beginning-with-artifactory)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
6. [Limitations - OS compatibility, etc.](#limitations)
7. [Development - Guide for contributing to the module](#development)

## Overview

This will install Artifactory OSS or PRO.
Artifactory 7+ is supported, legacy support for Artifactory 6 is still available.

Github and gitlab are great for storing source control, but bad at storing installers and compiled packages.

This is where Artifactory comes in. It stores all of your organizations artifacts in an organized and secure manner.

## Module Description

The Artifactory module installs, configures, and manages the Artifactory open source binary repository.

The Artifactory module manages both the installation and database configuration of Artifactory OSS.

## Setup

### Beginning with artifactory

If you want a server installed with the default options you can run
`include 'artifactory'`.

However, it is strongly recommended to specify the desired version of Artifactory:

```puppet
class { 'artifactory':
  package_version => '7.4.3',
```

This ensures that the module behaves correctly and does not enable obsolete features for your version of Artifactory.

If you need to add database connectivity instantiate with the required parameters:

```puppet
class { 'artifactory':
  jdbc_driver_url                => 'puppet:///modules/my_module/mysql.jar',
  db_type                        => 'oracle',
  db_url                         => 'jdbc:oracle:thin:@somedomain.com:1521:arti001',
  db_username                    => 'my_username',
  db_password                    => 'efw23gn2j3',
  binary_provider_type           => 'filesystem',
  pool_max_active                => 100,
  pool_max_idle                  => 10,
  binary_provider_cache_maxsize  => $binary_provider_cache_maxsize,
  binary_provider_filesystem_dir => '/var/opt/jfrog/artifactory/data/filestore',
  binary_provider_cache_dir      => '/var/opt/jfrog/artifactory/',
}
```

### Artifactory with PostgreSQL database

This installs PostgreSQL 11 and artifactory. PostgreSQL 12 isn't supported yet
by Artifactory.

```puppet
class {'postgresql::globals':
  version => '11',
  manage_package_repo => true,
}
include postgresql::server

postgresql::server::db {'artifactory':
  user => 'artifactory',
  password => postgresql_password('artifactory', 'RANDOM_PASSWORD_SHOULD_BE_INSERTED_HERE'),
}
class { 'artifactory':
  db_type => 'postgresql',
  db_username => 'artifactory',
  db_password => '45y43y58y435hitr',
  db_url      => 'jdbc:postgresql:127.0.0.1:5432/artifactory',
  require     => Postgresql::Server::Db['artifactory']
}
```

### Install commercial version

To install a commercial version of Artifactory:

```puppet
class { 'artifactory':
  edition     => 'pro',
  license_key => 'ABCDEFG1234567890',
  ...
}
```

## Usage

All interaction for the server is done via `artifactory`.

## Reference

Classes and parameters are documented in [REFERENCE.md](REFERENCE.md).

## Development

### Contributing

Please use the GitHub issues functionality to report any bugs or requests for new features. Feel free to fork and submit pull requests for potential contributions.

All contributions must pass all existing tests, new features should provide additional unit/acceptance tests.
