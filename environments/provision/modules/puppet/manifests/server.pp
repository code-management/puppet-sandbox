# == Class: puppet::server
#
# This class installs and manages the Puppet server daemon.
#
# === Parameters
#
# [*ensure*]
#   What state the package should be in. Defaults to +latest+. Valid values are
#   +present+ (also called +installed+), +absent+, +purged+, +held+, +latest+,
#   or a specific version number.
#
# [*package_name*]
#   The name of the package on the relevant distribution. Default is set by
#   Class['puppet::params'].
#
# === Actions
#
# - Install Puppet server package
# - Install puppet-lint gem
# - Configure Puppet to autosign puppet client certificate requests
# - Configure Puppet to use nodes.pp and modules from /vagrant directory
# - Ensure puppet-master daemon is running
#
# === Requires
#
# === Sample Usage
#
#   class { 'puppet::server': }
#
#   class { 'puppet::server':
#     ensure => 'puppet-2.7.17-1.el6',
#   }
#
class puppet::server(
  $ensure       = $puppet::params::server_ensure,
  $package_name = $puppet::params::server_package_name
) inherits puppet::params {

  # required to prevent syslog error on ubuntu
  # https://bugs.launchpad.net/ubuntu/+source/puppet/+bug/564861
  file { [ '/etc/puppetlabs' ]:
    ensure => directory,
    before => Package[ 'puppetserver' ],
  }

  package { 'puppetserver':
    ensure => $ensure,
    name   => $package_name,
  }

  package { 'puppet-lint':
    ensure   => latest,
    provider => gem,
  }

  file { 'puppet.conf':
    ensure  => file,
    path    => '/etc/puppetlabs/puppet/puppet.conf',
    owner   => 'puppet',
    group   => 'puppet',
    mode    => '0644',
    content => template('puppet/puppet.conf'),
    require => Package[ 'puppetserver' ],
    notify  => Service[ 'puppetserver' ],
  }

  file { 'site.pp':
    ensure  => file,
    path    => '/etc/puppetlabs/code/environments/production/manifests/site.pp',
    owner   => 'puppet',
    group   => 'puppet',
    mode    => '0644',
    content => template('puppet/site.pp'),
    require => Package[ 'puppetserver' ],
  }

  file { '/etc/default/puppetserver':
    ensure  => file,
    path    => '/etc/default/puppetserver',
    owner   => 'root',
    group   => 'root',
    mode    => '0744',
    content => template('puppet/puppetserver'),
    require => Package[ 'puppetserver' ],
  }

  file { 'autosign.conf':
    ensure  => file,
    path    => '/etc/puppetlabs/puppet/autosign.conf',
    owner   => 'puppet',
    group   => 'puppet',
    mode    => '0644',
    content => '*',
    require => Package[ 'puppetserver' ],
  }

  file { '/etc/puppetlabs/code/environments/production/manifests/nodes.pp':
    ensure  => link,
    target  => '/vagrant/environments/production/nodes.pp',
    require => Package[ 'puppetserver' ],
  }

  # initialize a template file then ignore
  file { '/vagrant/environments/production/manifests/nodes.pp':
    ensure  => file,
    replace => false,
    content => template('puppet/nodes.pp'),
  }

  service { 'puppetserver':
    ensure => running,
    enable => true,
  }

}
