# == Class: repos::apt
#
# This class installs the Puppet Labs APT repository.
#
# === Parameters
#
# === Actions
#
# - Install puppetlabs repository
# - Perform initial sync to update package database
#
# === Requires
#
# === Sample Usage
#
#   class { 'repos::apt': }
#
class repos::apt {

  exec { 'wget_repo_deb':
    command => "wget https://apt.puppetlabs.com/puppetlabs-release-pc1-${lsbdictcodename} -O /tmp/puppetlabs.deb",
    path    => '/usr/bin',
    creates => '/tmp/puppetlabs.deb',
  } ~>
  exec { 'install_repo_deb':
    command => 'sudo dpkg -i /tmp/puppetlabs.deb',
    path    => '/usr/bin',
  } ~>
  exec { 'apt_update':
    command     => '/usr/bin/apt-get update',
    refreshonly => true,
    timeout     => 0,
  }

}
