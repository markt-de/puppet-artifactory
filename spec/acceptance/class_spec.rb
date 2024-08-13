require 'spec_helper_acceptance'

describe 'artifactory class' do
  context 'with default parameters' do
    it 'works with no errors' do
      pp = <<-ARTIFACTORY_TEST
      class { 'artifactory':
        package_version => '7.90.7',
      }
      ARTIFACTORY_TEST

      # Run it twice and test for idempotency
      idempotent_apply(pp)
    end

    describe package('jfrog-artifactory-oss') do
      it { is_expected.to be_installed }
    end

    describe service('artifactory') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    describe port(8081) do
      it { is_expected.to be_listening }
    end
  end

  context 'with postgresql' do
    it 'works with no errors' do
      pp = <<-PUPPETCODE
      if $facts['os']['family'] == 'RedHat' {
        package { 'postgresql':
          ensure   => 'disabled',
          provider => 'dnfmodule',
        }
      }

      class {'postgresql::globals':
        encoding            => 'UTF-8',
        locale              => 'en_US.UTF-8',
        manage_dnf_module   => false,
        manage_package_repo => true,
        needs_initdb        => true,
        version             => '13',
      }
      include postgresql::server

      postgresql::server::db {'artifactory':
        user     => 'artifactory',
        password => postgresql::postgresql_password('artifactory', '45y43y58y435hitr'),
      }

      class { 'artifactory':
        db_type         => 'postgresql',
        db_username     => 'artifactory',
        db_password     => '45y43y58y435hitr',
        db_url          => 'jdbc:postgresql:127.0.0.1:5432/artifactory',
        package_version => '7.90.7',
        require         => Postgresql::Server::Db['artifactory']
      }
      PUPPETCODE

      # Run it twice and test for idempotency
      idempotent_apply(pp)
    end

    describe package('jfrog-artifactory-oss') do
      it { is_expected.to be_installed }
    end

    describe service('artifactory') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    describe port(8081) do
      it { is_expected.to be_listening }
    end
  end
end
