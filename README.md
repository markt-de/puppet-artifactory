# puppet-artifactory

[![Build Status](https://github.com/markt-de/puppet-artifactory/actions/workflows/ci.yaml/badge.svg)](https://github.com/markt-de/puppet-artifactory/actions/workflows/ci.yaml)
[![Puppet Forge](https://img.shields.io/puppetforge/v/markt/artifactory.svg)](https://forge.puppetlabs.com/markt/artifactory)
[![Puppet Forge - downloads](https://img.shields.io/puppetforge/dt/markt/artifactory.svg)](https://forge.puppetlabs.com/markt/artifactory)

#### Table of Contents

1. [Overview](#overview)
1. [Usage](#usage)
    - [Basic usage](#basic-usage)
    - [Archive installation](#archive-installation)
    - [Commercial editions](#commercial-editions)
    - [Complex example](#complex-example)
1. [Reference](#reference)
1. [Development](#development)
    - [Contributing](#contributing)
1. [License](#license)

## Overview

This module installs and configures JFrog Artifactory. Both the open source and commercial editions are supported.

Artifactory 7+ is recommended, but legacy support for Artifactory 6 is still available.

## Usage

### Basic usage

To setup Artifactory with default options only the desired version needs to be specified:

```puppet
class { 'artifactory':
  package_version => '7.90.7',
}
```

By default this module will install Artifactory from official RPM/DEB packages.

### Archive installation

It is also possible to install Artifactory from the official tar.gz archive, which provides more flexibility and customization options:

```puppet
class { 'artifactory':
  install_method  => 'archive',
  package_version => '7.90.7',
}
```

The archive installation allows to customize installation paths, see [reference](#reference) for details.

### Commercial editions

To install a commercial version of Artifactory:

```puppet
class { 'artifactory':
  edition         => 'pro',
  license_key     => 'ABCDEFG1234567890',
  package_version => '7.90.7',
  ...
}
```

### Complex example

```puppet
class { 'artifactory':
  binary_provider_type           => 'filesystem',
  binary_provider_cache_dir      => '/var/opt/jfrog/artifactory/',
  binary_provider_cache_maxsize  => 536870912000,
  binary_provider_filesystem_dir => '/var/opt/jfrog/artifactory/data/filestore',
  db_type                        => 'oracle',
  db_url                         => 'jdbc:oracle:thin:@example.com:1521:dbname',
  db_username                    => 'my_username',
  db_password                    => 'pa$$w0rd',
  jdbc_driver_url                => 'puppet:///modules/my_module/mysql.jar',
  package_version                => '7.90.7',
  pool_max_active                => 100,
  pool_max_idle                  => 10,
}
```

## Reference

Classes and parameters are documented in [REFERENCE.md](REFERENCE.md).

## Development

### Contributing

Please use the GitHub issues functionality to report any bugs or requests for new features. Feel free to fork and submit pull requests for potential contributions.

All contributions must pass all existing tests, new features should provide additional unit/acceptance tests.

## License

This module is a fork of fervidus/artifactory.

Copyright 2024 markt.de GmbH & Co. KG

Copyright 2016-2021 Bryan Belanger
