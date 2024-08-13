# @summary Configure the Artifactory system service.
# @api private
class artifactory::service {
  service { 'artifactory':
    ensure => running,
    enable => true,
  }
}
