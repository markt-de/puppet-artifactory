require 'spec_helper'

describe 'artifactory' do
  context 'supported operating systems' do
    on_supported_os.each do |os, os_facts|
      context "on #{os}" do
        let(:facts) { os_facts.merge('root_home' => '/root') }

        context 'artifactory with default config' do
          let(:params) do
            {
              'package_version' => '7.90.7',
            }
          end

          it { is_expected.to compile.with_all_deps }

          it { is_expected.to contain_class('artifactory::install').that_comes_before('Class[artifactory::config]') }
          it { is_expected.to contain_class('artifactory::config') }
          it { is_expected.to contain_class('artifactory::service') } # .that_subscribes_to('Class[artifactory::config]') }

          it { is_expected.to contain_service('artifactory') }
          it { is_expected.to contain_package('jfrog-artifactory-oss').with_ensure('7.90.7') }

          it { is_expected.to contain_class('artifactory') }
          case os_facts[:os]['family']
          when 'Debian'
            it { is_expected.to contain_class('artifactory::repo::apt') }
            it {
              is_expected.to contain_apt__source('artifactory').with(
                               'location' => 'https://releases.jfrog.io/artifactory/artifactory-debs',
                               'release'  => os_facts[:os]['distro']['codename'],
                               'repos'    => 'main',
                             )
            }
          else
            it { is_expected.to contain_class('artifactory::repo::yum') }
            it {
              is_expected.to contain_yumrepo('bintray-jfrog-artifactory-rpms').with(
                               'baseurl'  => 'https://jfrog.bintray.com/artifactory-rpms',
                               'descr'    => 'bintray-jfrog-artifactory-rpms',
                               'gpgcheck' => '1',
                               'enabled'  => '1',
                               'gpgkey'   => 'https://jfrog.bintray.com/artifactory-rpms/repodata/repomd.xml.key',
                             )
            }
          end
        end

        context 'artifactory with master_key parameter' do
          let(:params) do
            {
              'master_key' => 'masterkey',
              'package_version' => '7.90.7',
            }
          end

          it { is_expected.to compile.with_all_deps }

          it {
            is_expected.to contain_file('/var/opt/jfrog/artifactory/etc/artifactory/security/master.key').with(
              'content' => 'masterkey',
              'mode' => '0640',
              'owner' => 'artifactory',
              'group' => 'artifactory',
            )
          }
        end

        context 'artifactory with jdbc_driver_url parameter' do
          let(:params) do
            {
              'db_password' => 'password',
              'db_url' => 'oracle://some_url',
              'db_username' => 'username',
              'db_type' => 'oracle',
              'jdbc_driver_url' => 'puppet:///modules/my_module/mysql.jar',
              'package_version' => '7.90.7',
            }
          end

          it { is_expected.to compile.with_all_deps }

          it {
            is_expected.to contain_file('/var/opt/jfrog/artifactory/bootstrap/artifactory/tomcat/lib/mysql.jar').with(
              'source' => 'puppet:///modules/my_module/mysql.jar',
              'mode' => '0775',
              'owner' => 'root',
            )
          }

          it {
            is_expected.to contain_file('/var/opt/jfrog/artifactory/etc/artifactory/.secrets/.temp.db.properties').with(
              'ensure' => 'file',
              'mode' => '0640',
              'owner' => 'artifactory',
              'group' => 'artifactory',
            )
          }
        end

        context 'running a legacy version (pre v7)' do
          let(:params) do
            {
              'package_version' => '6.0.0',
              'use_temp_db_secrets' => true,
            }
          end

          it { is_expected.to compile.with_all_deps }
          it {
            is_expected.to contain_package('jfrog-artifactory-oss').with(
              'ensure' => '6.0.0',
            )
          }
          it {
            is_expected.to contain_file('/var/opt/jfrog/artifactory/etc/binarystore.xml').with_content(%r{chain template="file-system"})
            is_expected.to contain_file('/var/opt/jfrog/artifactory/etc/binarystore.xml').without_content(%r{<provider id="file-system" type="file-system">})
            is_expected.to contain_file('/var/opt/jfrog/artifactory/etc/binarystore.xml').without_content(%r{<fileStoreDir>})
            is_expected.to contain_file('/var/opt/jfrog/artifactory/etc/binarystore.xml').without_content(%r{<baseDataDir>})
          }
        end

        context 'running a legacy version (pre v7) with jdbc_driver_url parameter' do
          let(:params) do
            {
              'db_password' => 'password',
              'db_url' => 'oracle://some_url',
              'db_username' => 'username',
              'db_type' => 'oracle',
              'jdbc_driver_url' => 'puppet:///modules/my_module/mysql.jar',
              'package_version' => '6.0.0',
            }
          end

          it { is_expected.to compile.with_all_deps }
          it {
            is_expected.to contain_file('/var/opt/jfrog/artifactory/etc/storage.properties').with(
              'ensure' => 'link',
              'target' => '/var/opt/jfrog/artifactory/etc/.secrets/.temp.db.properties',
            )
          }
        end

        context 'running a legacy version (pre v7) with use_temp_db_secrets set to false' do
          let(:params) do
            {
              'db_password' => 'foopw',
              'db_type' => 'oracle',
              'db_url' => 'oracle://some_url',
              'db_username' => 'foouser',
              'jdbc_driver_url' => 'puppet:///modules/my_module/mysql.jar',
              'package_version' => '6.0.0',
              'use_temp_db_secrets' => false,
            }
          end

          it { is_expected.to compile.with_all_deps }

          it {
            is_expected.to contain_file('/var/opt/jfrog/artifactory/etc/storage.properties').with(
              'ensure' => 'link',
              'target' => '/var/opt/jfrog/artifactory/etc/db.properties',
            )
          }
          it {
            is_expected.to contain_file('/var/opt/jfrog/artifactory/etc/db.properties').with(
              'ensure' => 'file',
              'mode' => '0640',
              'owner' => 'artifactory',
              'group' => 'artifactory',
            )
          }
          it do
            is_expected.to contain_augeas('db.properties').with('changes' => [
                                                                  'set "type" "oracle"',
                                                                  'set "url" "oracle://some_url"',
                                                                  'set "driver" "oracle.jdbc.OracleDriver"',
                                                                  'set "username" "foouser"',
                                                                  'set "binary.provider.type" "file-system"',
                                                                ],
                                                                'require' => ['Class[Artifactory::Install]'],
                                                                'notify'  => 'Class[Artifactory::Service]')
          end
          it do
            is_expected.to contain_augeas('db.properties.pw').with('changes' => [
                                                                     'set "password" "foopw"',
                                                                   ],
                                                                   'onlyif'  => 'match /files/var/opt/jfrog/artifactory/etc/db.properties/password size == 0',
                                                                   'require' => ['Class[Artifactory::Install]'],
                                                                   'notify'  => 'Class[Artifactory::Service]')
          end
        end

        context 'running a current version' do
          let(:params) do
            {
              'package_version' => '7.90.7',
            }
          end

          it { is_expected.to compile.with_all_deps }
          it {
            is_expected.to contain_package('jfrog-artifactory-oss').with(
              'ensure' => '7.90.7',
            )
          }
          it {
            is_expected.to contain_file('/var/opt/jfrog/artifactory/etc/artifactory/binarystore.xml').with_content(%r{chain template="file-system"})
            is_expected.to contain_file('/var/opt/jfrog/artifactory/etc/artifactory/binarystore.xml').without_content(%r{<provider id="file-system" type="file-system">})
            is_expected.to contain_file('/var/opt/jfrog/artifactory/etc/artifactory/binarystore.xml').without_content(%r{<fileStoreDir>})
            is_expected.to contain_file('/var/opt/jfrog/artifactory/etc/artifactory/binarystore.xml').without_content(%r{<baseDataDir>})
          }
        end

        context 'running a current version with a custom binary filesystem dir' do
          let(:params) do
            {
              'package_version' => '7.90.7',
              'binary_provider_filesystem_dir' => '/opt/artifactory-filestore',
            }
          end

          it { is_expected.to compile.with_all_deps }
          it {
            is_expected.to contain_file('/var/opt/jfrog/artifactory/etc/artifactory/binarystore.xml').with_content(%r{<provider id="file-system" type="file-system">})
            is_expected.to contain_file('/var/opt/jfrog/artifactory/etc/artifactory/binarystore.xml').with_content(%r{<fileStoreDir>/opt/artifactory-filestore</fileStoreDir>})
            is_expected.to contain_file('/var/opt/jfrog/artifactory/etc/artifactory/binarystore.xml').without_content(%r{<baseDataDir>})
          }
        end

        context 'running a current version with a custom binary base data dir' do
          let(:params) do
            {
              'package_version' => '7.90.7',
              'binary_provider_base_data_dir' => '/opt/artifactory-data',
            }
          end

          it { is_expected.to compile.with_all_deps }
          it {
            is_expected.to contain_file('/var/opt/jfrog/artifactory/etc/artifactory/binarystore.xml').with_content(%r{<baseDataDir>/opt/artifactory-data</baseDataDir>})
            is_expected.to contain_file('/var/opt/jfrog/artifactory/etc/artifactory/binarystore.xml').with_content(%r{<fileStoreDir>/opt/artifactory-data/filestore</fileStoreDir>})
          }
        end

        context 'running a current version with s3 storage provider' do
          let(:params) do
            {
              'package_version' => '7.90.7',
              'binary_provider_type' => 's3',
              'binary_provider_config_hash' => {
                'endpoint' => 's3.amazonaws.com',
                'useInstanceCredentials' => true,
                'bucketName' => 'art-bucket',
                'region' => 'eu-central-1',
              }
            }
          end

          it { is_expected.to compile.with_all_deps }
          it {
            is_expected.to contain_file('/var/opt/jfrog/artifactory/etc/artifactory/binarystore.xml').with_content(%r{<provider id="s3-storage-v3" type="s3-storage-v3">})
            is_expected.to contain_file('/var/opt/jfrog/artifactory/etc/artifactory/binarystore.xml').with_content(%r{<bucketName>art-bucket</bucketName>})
            is_expected.to contain_file('/var/opt/jfrog/artifactory/etc/artifactory/binarystore.xml').with_content(%r{<useInstanceCredentials>true</useInstanceCredentials>})
          }
        end
      end
    end
  end
end
