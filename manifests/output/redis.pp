# == Define: beaver::output::redis
#
#   send events to a redis database using RPUSH  For more information
#   about redis, see http://redis.io/
#
#
# === Parameters
#
# [*host*]
#   Redis host to submit to
#   Value type is string
#   This variable is mandatory
#
# [*port*]
#   Redis port number
#   Value type is number
#   Default value: 6379
#   This variable is optional
#
# [*db*]
#   Redis database number
#   Value type is number
#   Default value: 0
#   This variable is optional

# [*namespace*]
#   Redis key namespace
#   Value type is string
#   Default value: logstash:beaver
#   This variable is optional
#
# === Examples
#
#  beaver::output::redis{'redisout':
#    host => 'redishost'
#  }
#
# === Authors
#
# * Richard Pijnenburg <mailto:richard@ispavailability.com>
#
define beaver::output::redis(
  $host,
  $port      = 6379,
  $db        = 0,
  $namespace = 'logstash:beaver'
) {

  #### Validate parameters
  if $host {
    validate_string($host)
  }

  if ! is_numeric($port) {
    fail("\"${port}\" is not a valid port parameter value")
  }

  if ! is_numeric($db) {
    fail("\"${db}\" is not a valid db parameter value")
  }

  $opt_url = "redis_url: redis://${host}:${port}/${db}\n"

  if ($namespace != '') {
    validate_string($namespace)
    $opt_namespace = "redis_namespace: ${$namespace}\n"
  }

  #### Create file fragment

  file_fragment{ "output_redis_${::fqdn}":
    tag     => "beaver_config_${::fqdn}",
    content => "${opt_url}${opt_namespace}\n",
    order   => 20
  }

}
