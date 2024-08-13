# @summary Setup YUM repository on RedHat-based distributions
# @api private
class artifactory::repo::yum {
  if $artifactory::manage_repo {
    case $artifactory::edition {
      'enterprise', 'pro': {
        $_gpg = $artifactory::yum_gpgkey_pro
        $_url = $artifactory::yum_baseurl_pro
      }
      default: {
        $_gpg = $artifactory::yum_gpgkey
        $_url = $artifactory::yum_baseurl
      }
    }

    # Add the jfrog yum repo
    yumrepo { $artifactory::yum_name:
      baseurl  => $_url,
      descr    => $artifactory::yum_name,
      gpgcheck => 1,
      enabled  => 1,
      gpgkey   => $_gpg,
    }
  }
}
