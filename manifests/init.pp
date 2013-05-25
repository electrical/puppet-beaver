# == Class: beaver
#
# This class is able to install or remove beaver on a node.
# It manages the status of the related service.
#
#
#
# === Parameters
#
# [*ensure*]
#   String. Controls if the managed resources shall be <tt>present</tt> or
#   <tt>absent</tt>. If set to <tt>absent</tt>:
#   * The managed software packages are being uninstalled.
#   * Any traces of the packages will be purged as good as possible. This may
#     include existing configuration files. The exact behavior is provider
#     dependent. Q.v.:
#     * Puppet type reference: {package, "purgeable"}[http://j.mp/xbxmNP]
#     * {Puppet's package provider source code}[http://j.mp/wtVCaL]
#   * System modifications (if any) will be reverted as good as possible
#     (e.g. removal of created users, services, changed log settings, ...).
#   * This is thus destructive and should be used with care.
#   Defaults to <tt>present</tt>.
#
# [*autoupgrade*]
#   Boolean. If set to <tt>true</tt>, any managed package gets upgraded
#   on each Puppet run when the package provider is able to find a newer
#   version than the present one. The exact behavior is provider dependent.
#   Q.v.:
#   * Puppet type reference: {package, "upgradeable"}[http://j.mp/xbxmNP]
#   * {Puppet's package provider source code}[http://j.mp/wtVCaL]
#   Defaults to <tt>false</tt>.
#
# [*status*]
#   String to define the status of the service. Possible values:
#   * <tt>enabled</tt>: Service is running and will be started at boot time.
#   * <tt>disabled</tt>: Service is stopped and will not be started at boot
#     time.
#   * <tt>running</tt>: Service is running but will not be started at boot time.
#     You can use this to start a service on the first Puppet run instead of
#     the system startup.
#   * <tt>unmanaged</tt>: Service will not be started at boot time and Puppet
#     does not care whether the service is running or not. For example, this may
#     be useful if a cluster management software is used to decide when to start
#     the service plus assuring it is running on the desired node.
#   Defaults to <tt>enabled</tt>. The singular form ("service") is used for the
#   sake of convenience. Of course, the defined status affects all services if
#   more than one is managed (see <tt>service.pp</tt> to check if this is the
#   case).
#
# [*version*]
#   String to set the specific version you want to install.
#   Defaults to <tt>false</tt>.
#
# [*format*]
#   format to transfer in
#   Value can be any of: "json", "repack", "string"
#   Default value: "json"
#   This variable is optional
#
# [*respawn_delay*]
#   Delay for respawning the output thread
#   Value type is number
#   Default value: 3
#   This variable is optional
#
# [*max_failure*]
#   Number of times the respawn of an output thread is done
#   Value type is number
#   Default value: 7
#   This variable is optional
#
# [*hostname*]
#   Name to use in the @source_host variable.
#   Value type is string
#   Default value: FQDN
#   This variable is optional
#
# [*transport(]
#  Transport method to use
#  Value can be any of: "redis", "rabbitmq", "zeromq", "udp"
#  Default value: "redis"
#  This variable is optional
#
# The default values for the parameters are set in beaver::params. Have
# a look at the corresponding <tt>params.pp</tt> manifest file if you need more
# technical information about them.
#
#
# === Examples
#
# * Installation, make sure service is running and will be started at boot time:
#     class { 'beaver': }
#
# * Removal/decommissioning:
#     class { 'beaver':
#       ensure => 'absent',
#     }
#
# * Install everything but disable service(s) afterwards
#     class { 'beaver':
#       status => 'disabled',
#     }
#
#
# === Authors
#
# * Richard Pijnenburg <mailto:richard@ispavailability.com>
#
class beaver(
  $ensure        = $beaver::params::ensure,
  $autoupgrade   = $beaver::params::autoupgrade,
  $status        = $beaver::params::status,
  $version       = false,
  $format        = 'json',
  $respawn_delay = 3,
  $max_failure   = 7,
  $hostname      = $::fqdn,
  $transport     = 'redis'
) inherits beaver::params {

  #### Validate parameters

  # ensure
  if ! ($ensure in [ 'present', 'absent' ]) {
    fail("\"${ensure}\" is not a valid ensure parameter value")
  }

  # autoupgrade
  validate_bool($autoupgrade)

  # service status
  if ! ($status in [ 'enabled', 'disabled', 'running', 'unmanaged' ]) {
    fail("\"${status}\" is not a valid status parameter value")
  }

  if ! ($format in [ 'json', 'msgpack', 'string', 'raw' ]) {
    fail("\"${format}\" is not a valid format parameter value")
  }

  if ! is_numeric($respawn_delay) {
    fail("\"${respawn_delay}\" is not a valid respawn_delay parameter value")
  }

  if ! is_numeric($max_failure) {
    fail("\"${max_failure}\" is not a valid max_failure parameter value")
  }

  validate_string($hostname)

  if ! ($transport in [ 'redis', 'rabbitmq', 'zmq', 'udp', 'mqtt', 'sqs' ]) {
    fail("\"${transport}\" is not a valid transport parameter value")
  }

  $config = "hostname: ${hostname}\nformat: ${format}\nrespawn_delay: ${respawn_delay}\nmax_failure: ${max_failure}\ntransport: ${transport}"

  #### Manage actions

  anchor {'beaver::begin': }
  anchor {'beaver::end': }

  # package(s)
  class { 'beaver::package': }

  # configuration
  class { 'beaver::config': }

  # service(s)
  class { 'beaver::service': }


  #### Manage relationships

  if $ensure == 'present' {
    # we need the software before configuring it
    Anchor['beaver::begin']
    -> Class['beaver::package']
    -> Class['beaver::config']

    # we need the software and a working configuration before running a service
    Class['beaver::package'] -> Class['beaver::service']
    Class['beaver::config']  -> Class['beaver::service']

    Class['beaver::service']
    -> Anchor['beaver::end']
  } else {

    # make sure all services are getting stopped before software removal
    Anchor['beaver::begin']
    -> Class['beaver::service']
    -> Class['beaver::package']
    -> Anchor['beaver::end']
  }

}
