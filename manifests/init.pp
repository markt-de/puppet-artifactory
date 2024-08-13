# @summary Install and configure Artifactory.
#
# @param apt_baseurl
#   Sets the URL of the APT repository.
#
# @param apt_baseurl_pro
#   Sets the URL of the APT repository (Pro edition).
#
# @param apt_key_id
#   Sets the ID of the APT repository key.
#
# @param apt_key_source
#   Sets the URL of the APT repository.
#
# @param apt_repos
#   Sets the names of the APT repositories to enable.
#
# @param archive_data_dir
#   The Artifactory data directory that should be used for archive installations.
#
# @param archive_install_dir
#   The Artifactory app directory that should be used for archive installations.
#
# @param artifactory_home
#   Specifies the main directory.
#
# @param binary_provider_base_data_dir
#   The filestore base location. Defaults to '$ARTIFACTORY_HOME/data'.
#
# @param binary_provider_cache_dir
#   The location of the cache. This should be set to the $ARTIFACTORY_HOME
#   directory (not on NFS).
#
# @param binary_provider_cache_maxsize
#   This value specifies the maximum cache size (in bytes) to allocate for
#   caching BLOBs.
#
# @param binary_provider_config_hash
#   A hash containing configuration options for the binary provider.
#
# @param binary_provider_filesystem_dir
#   If the `$binary_provider_type` is set to `filesystem`, this value specifies
#   the location of the binaries in combination with `$binary_provider_base_data_dir`.
#
# @param binary_provider_type
#   Optional setting for the binary storage provider. The type of database to
#   configure. Valid values are 'filesystem', 'fullDb', 'cachedFS', 'S3'.
#   Defaults to 'filesystem'.
#
# @param config_group
#   Specifies the group owner of the configuration files.
#
# @param config_owner
#   Specifies the owner of the configuration files.
#
# @param db_automate
#   Set to 'true' to let Puppet create a database (instance). Only supports MySQL.
#
# @param db_password
#   The password for the database account. Only required for database configuration.
#
# @param db_type
#   The type of database to configure. Only required for database configuration.
#
# @param db_url
#   The url of the database. Only required for database configuration.
#
# @param db_username
#   The username for the database account. Only required for database configuration.
#
# @param download_filename
#   The filename of the archive distribution.
#
# @param download_url_oss
#   The download URL for the open-source edition.
#
# @param download_url_pro
#   The download URL for the pro edition.
#
# @param edition
#   Specifies the Artifactory edition/license.
#
# @param install_method
#   Whether to use a package or an archive to install artifactory.
#
# @param install_service_script
#   Path to the installation script of the archive distribution.
#
# @param jdbc_driver_url
#   Sets the download location for the jdbc driver.
#
# @param license_key
#   Specifies the license key (only commercial editions).
#
# @param manage_repo
#   Whether to setup required repos or disable repo management.
#
# @param master_key
#   The master key that Artifactory uses to connect to the database.
#   If specified, it ensures that if the node terminates, a new one
#   can be spun up that can connect to the same database as before.
#   Otherwise, Artifactory will generate a new master key on first run.
#
# @param package_name
#   Sets the package name to install.
#
# @param package_name_pro
#   Sets the package name to install (Pro edition).
#
# @param package_version
#   Specifies the package version.
#
# @param pool_max_active
#   Maximum number of pooled database connections.
#
# @param pool_max_idle
#   Maximum number of pooled idle database connections.
#
# @param root_password
#   Sets the root password for Puppet managed mysql database instance.
#
# @param symlink_name
#   Controls the name of a version-independent symlink for the archive
#   installation. It will always point to the release specified by `$package_version`.
#
# @param use_temp_db_secrets
#   Set to `true` to delete the temporary db.properties file on service start.
#   Set to `false` to persist the file in `$artifactory_home/etc/db.properties`,
#   which will allow to add database and storage options without Puppet
#   touching it.
#
# @param yum_baseurl
#   Sets the URL of the yum repository.
#
# @param yum_baseurl_pro
#   Sets the URL of the yum repository (Pro edition).
#
# @param yum_name
#   Sets the name of the yum repository.
#
class artifactory (
  Enum['oss', 'pro', 'enterprise'] $edition                                                = 'oss',
  Boolean $manage_repo                                                                     = true,
  Boolean $use_temp_db_secrets                                                             = true,
  String $yum_name                                                                         = 'bintray-jfrog-artifactory-rpms',
  String $yum_baseurl                                                                      = 'https://jfrog.bintray.com/artifactory-rpms',
  String $yum_baseurl_pro                                                                  = 'https://jfrog.bintray.com/artifactory-pro-rpms',
  String $apt_baseurl                                                                      = 'https://releases.jfrog.io/artifactory/artifactory-debs',
  String $apt_baseurl_pro                                                                  = 'https://releases.jfrog.io/artifactory/artifactory-pro-debs',
  String $apt_key_id                                                                       = 'A3D085F542F740BBD7E3A2846B219DCCD7639232',
  String $apt_key_source                                                                   = 'https://releases.jfrog.io/artifactory/api/gpg/key/public',
  String $apt_repos                                                                        = 'main',
  String $package_name                                                                     = 'jfrog-artifactory-oss',
  String $package_name_pro                                                                 = 'jfrog-artifactory-pro',
  String $package_version                                                                  = 'present',
  String $artifactory_home                                                                 = '/var/opt/jfrog/artifactory',
  String $install_method                                                                   = 'package',
  String $download_filename                                                                = 'jfrog-artifactory-%s-%s-linux.tar.gz',
  String $download_url_oss                                                                 = 'https://releases.jfrog.io/artifactory/bintray-artifactory/org/artifactory/oss/jfrog-artifactory-oss/%s/%s',
  String $download_url_pro                                                                 = 'https://releases.jfrog.io/artifactory/artifactory-pro/org/artifactory/pro/jfrog-artifactory-pro/%s/%s',
  String $symlink_name                                                                     = 'artifactory',
  String $install_service_script                                                           = 'app/bin/installService.sh',
  Stdlib::Absolutepath $archive_install_dir                                                = '/opt',
  Stdlib::Absolutepath $archive_data_dir                                                   = '/opt/artifactory-data',
  Optional[String] $config_owner                                                           = 'artifactory',
  Optional[String] $config_group                                                           = 'artifactory',
  Optional[String] $root_password                                                          = 'password',
  Optional[String] $jdbc_driver_url                                                        = undef,
  Optional[Enum['derby', 'mariadb', 'mssql', 'mysql', 'oracle', 'postgresql']] $db_type    = undef,
  Optional[String] $db_url                                                                 = undef,
  Optional[String] $db_username                                                            = undef,
  Optional[String] $db_password                                                            = undef,
  Optional[Boolean] $db_automate                                                           = false,
  Optional[Enum['filesystem', 'fullDb', 'cachedFS', 'fullDbDirect', 's3']] $binary_provider_type = undef,
  Optional[Integer] $pool_max_active                                                       = undef,
  Optional[Integer] $pool_max_idle                                                         = undef,
  Optional[Integer] $binary_provider_cache_maxsize                                         = undef,
  Optional[String] $binary_provider_base_data_dir                                          = undef,
  Optional[String] $binary_provider_filesystem_dir                                         = undef,
  Optional[String] $binary_provider_cache_dir                                              = undef,
  Optional[Hash] $binary_provider_config_hash                                              = undef,
  Optional[String] $master_key                                                             = undef,
  Optional[String] $license_key                                                            = undef,
) {
  $service_name = 'artifactory'

  # Artifactory's data directory depends on the installation method.
  if ($install_method == 'package') {
    $data_directory = $artifactory_home
  } else {
    $data_directory = $archive_data_dir
  }

  Class { 'artifactory::repo': }
  -> Class { 'artifactory::install': }
  -> Class { 'artifactory::config': }
  -> Class { 'artifactory::service': }
}
