# == Class: beaver::config
#
# This class exists to coordinate all configuration related actions,
# functionality and logical units in a central place.
#
#
# === Parameters
#
# This class does not provide any parameters.
#
#
# === Examples
#
# This class may be imported by other classes to use its functionality:
#   class { 'beaver::config': }
#
# It is not intended to be used directly by external resources like node
# definitions or other modules.
#
#
# === Authors
#
# * Richard Pijnenburg <mailto:richard@ispavailability.com>
#
class beaver::config {

  #### Configuration

  file { '/etc/beaver/':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0644'
  }

  file_fragment { 'header':
    tag     => "beaver_config_${::fqdn}",
    content => "[beaver]\n${beaver::config}\n",
    order   => 10
  }

  file_concat { '/etc/beaver/beaver.conf':
    tag     => "beaver_config_${::fqdn}",
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => Service['beaver'],
    require => File['/etc/beaver/']
  }

}
