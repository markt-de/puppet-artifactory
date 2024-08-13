# @summary Call the configured installation class
# @api private
class artifactory::install {
  case $artifactory::install_method {
    'package': {
      contain artifactory::install::package
      Class['artifactory::install::package']
    }
    'archive': {
      contain artifactory::install::archive
      Class['artifactory::install::archive']
    }
    default : {
      fail("install method ${artifactory::install_method} is not supported")
    }
  }
}
