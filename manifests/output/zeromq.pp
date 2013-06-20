# == Define: beaver::output::zeromq
#
#   send events to a zeromq host
#
# === Parameters
#
# [*host*]
#   The hostname of your zeromq server ( only used with connect type )
#   Value type is string
#   This variable is optional
#
# [*port*]
#   The default port to connect
#   Value type is number
#   Default value: 2120
#   This variable is optional
#
# [*hwm*]
#   Zeromq HighWaterMark socket option
#   Value type is number
#   This variable is optional
#
# [*type*]
#   Run either as a client ( connect ) or server ( bind )
#   Value can be any of: "bind", "connect"
#   Default value: 'bind'
#   This variable is optional
#
# === Examples
#
#  Connect to remote zeromq host
#
#  beaver::output::zeromq{ 'zeromqout':
#    host => 'zeromqhost',
#    type => 'connect'
#  }
#
#  Start zeromq server
#
#  beaver::output::zeromq{ 'zeromqout':
#    type => 'bind'
#  }
#
# === Authors
#
# * Richard Pijnenburg <mailto:richard@ispavailability.com>
#
define beaver::output::zeromq(
  $host = '',
  $port = 2120,
  $type = 'bind',
  $hwm  = ''
) {

  #### Validate parameters

  if ( $hwm != '') {
    if ! is_numeric($hwm) {
      fail("\"${hwm}\" is not a valid hwm parameter value")
    } else {
      $opt_hwm = "zeromq_hwm: ${hwm}\n"
    }
  }

  if ! is_numeric($port) {
    fail("\"${port}\" is not a valid port parameter value")
  }

  if ($host != '') {
    validate_string($host)
  }

  case $type {
    'bind': {
        $opt_url = "zeromq_address: tcp://*:${port}\n"
    }
    'connect': {
      if ($host == '') {
        fail('\'host\' variable is required when using the connect type')
      }
      $opt_url = "zeromq_address: tcp://${host}:${port}\n"
    }
    default: {
      fail("\"${type}\" is not a valid type parameter value")
    }
  }

  $opt_type = "zeromq_bind: ${type}\n"

  #### Create file fragment

  file_fragment{ "output_zeromq_${::fqdn}":
    tag     => "beaver_config_${::fqdn}",
    content => "${opt_url}${opt_type}${opt_hwm}\n",
    order   => 20
  }

}
