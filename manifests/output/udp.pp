# == Define: beaver::output::udp
#
#   send events to a udp host
#
# === Parameters
#
# [*host*]
#   The hostname to connect to.
#   Value type is string
#   This variable is mandatory
#
# [*port*]
#   The port to connect to
#   Value type is number
#   Default value: 9999
#   This variable is mandatory
#
# === Examples
#
#  beaver::output::udp{ 'udpout':
#    host => 'udphost'
#    port => 9999
#  }
#
# === Authors
#
# * Richard Pijnenburg <mailto:richard@ispavailability.com>
#
define beaver::output::udp(
  $host,
  $port
) {

  #### Validate parameters
  if ($host != '') {
    validate_string($host)
    $opt_host = "udp_host: ${host}\n"
  }

  if ($port != '') {
    if ! is_numeric($port) {
      fail("\"${port}\" is not a valid port parameter value")
    } else {
      $opt_port = "udp_port: ${port}\n"
    }
  }

  #### Create file fragment

  file_fragment{ "output_udp_${::fqdn}":
    tag     => "beaver_config_${::fqdn}",
    content => "${opt_host}${opt_port}\n",
    order   => 20
  }

}
