# == Define: beaver::input::file
#
#  Add a file to be processed by beaver
#
# === Parameters
#
# [*file*]
#   Path to the filename you want to transfer
#   Value type is string
#   This variable is mandatory
#
# [*tags*]
#   Tags to add
#   Value type is array
#   This variable is optional
#
# [*type*]
#   Type to add
#   Value type is string
#   This variable is optional
#
# [*add_fields*]
#   Fields with values to add
#   Value type is hash
#   This variable is optional
#
# [*format*]
#
# [*exclude*]
#
# [*sincedb_write_interval*]
#
# [*stat_interval*]
#
# === Examples
#
#  beaver::input::file { 'apachelog':
#    file => '/var/log/apache/access.log',
#    type => 'apache-access'
#  }
#
# === Authors
#
# * Richard Pijnenburg <mailto:richard@ispavailability.com>
#
define beaver::input::file(
  $file,
  $tags                   = '',
  $type                   = '',
  $add_fields             = '',
  $format                 = '',
  $exclude                = '',
  $sincedb_write_interval = '',
  $stat_interval          = ''
) {

  #### Validate parameters
  if ($tags != '') {
    validate_array($tags)
    $arr_tags = join($tags, ',')
    $opt_tags = "tags: ${arr_tags}\n"
  }

  if ($type != '') {
    validate_string($type)
    $opt_type = "type: ${type}\n"
  }

  if ($add_fields != '') {
    validate_hash($add_fields)
    $arr_add_fields = inline_template('<%= add_fields.sort.collect { |k,v| "\"#{k}\", \"#{v}\"" }.join(",") %>')
    $opt_add_fields = "add_field: ${arr_add_fields}\n"
  }

  if ($format != '') {
    if ! ($format in ['string', 'json', 'json_raw', 'msgpack', 'raw']) {
      fail("\"${format}\" is not a valid format parameter value")
    } else {
      $opt_format = "format: ${format}\n"
    }
  }

  if ($sincedb_write_interval != '') {
    if ! is_numeric($sincedb_write_interval) {
      fail("\"${sincedb_write_interval}\" is not a valid sincedb_write_interval parameter value")
    } else {
      $opt_sincedb_write_interval = "sincedb_write_interval: ${sincedb_write_interval}\n"
    }
  }

  if ($stat_interval != '') {
    if ! is_numeric($stat_interval) {
      fail("\"${stat_interval}\" is not a valid stat_interval parameter value")
    } else {
      $opt_stat_interval = "stat_interval => ${stat_interval}\n"
    }
  }

  validate_string($file)

  #### Write config file

  file_fragment{"input_file_${name}_${::fqdn}":
    tag     => "beaver_config_${::fqdn}",
    content => "[${file}]\n${opt_tags}${opt_type}${opt_add_fields}${opt_format}${opt_sincedb_write_interval}${opt_stat_interval}\n",
    order   => 30
  }

}
