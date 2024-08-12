# == Class artifactory::repo::apt
#
# @summary Set up the apt repo on Debian-based distros
# @api private
class artifactory::repo::apt () {
  assert_private()

  include apt

  case $artifactory::edition {
    'enterprise', 'pro' : {
      $_url = $artifactory::apt_baseurl_pro
    }
    default : {
      $_url = $artifactory::apt_baseurl
    }
  }

  apt::source { 'artifactory':
    location => $_url,
    release  => $facts['os']['distro']['codename'],
    repos    => $artifactory::apt_repos,
    include  => {
      'src' => false,
    },
    key      => {
      'id'     => $artifactory::apt_key_id,
      'source' => $artifactory::apt_key_source,
    },
  }
}
