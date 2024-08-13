# @summary Install artifactory from package
# @api private
class artifactory::install::package {
  case $artifactory::edition {
    'enterprise', 'pro' : {
      $_package = $artifactory::package_name_pro
    }
    default : {
      $_package = $artifactory::package_name
    }
  }

  package { $_package:
    ensure  => $artifactory::package_version,
  }

  if $facts['os']['family'] == 'Debian' {
    exec { 'fix permissions of artifactory log directory' :
      path        => '/usr/bin:/bin:/usr/local/bin:/usr/sbin:/sbin:/usr/local/sbin',
      command     => "chown -R ${artifactory::config_owner}:${artifactory::config_group} ${artifactory::data_directory}/log",
      refreshonly => true,
      subscribe   => [
        Package[$_package],
      ],
    }
  }
}
