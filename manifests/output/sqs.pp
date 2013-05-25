# == Define: beaver::output::sqs
#
#   send events to a sqs AWS service
#
# === Parameters
#
# [*access_key*]
#   The access key. Can be left blank to use IAM Roles
#   Value type is string
#   This variable is optional
#
# [*secret_key*]
#   The secret key. Can be left blank to use IAM Roles
#   Value type is string
#   This variable is optional
#
# [*region*]
#   AWS Region
#   Value type is string
#   Default value: us-east-1
#   This variable is optional
#
# [*queue*]
#   SQS queue (must exist)
#   Value type is string
#   This variable is mandatory
#
# === Examples
#
#  beaver::output::sqs { 'sqs_output':
#    access_key => 'accesskey',
#    secret_key => 'secretkey',
#    region     => 'us-east-1',
#    queue      => 'queue'
#  }
#
# === Authors
#
# * Richard Pijnenburg <mailto:richard@ispavailability.com>
#
define beaver::output::sqs(
  $queue,
  $access_key = '',
  $secret_key = '',
  $region     = ''
) {

  #### Validate parameters
  if ($access_key != '') {
    validate_string($access_key)
    $opt_access_key = "sqs_aws_access_key: ${access_key}\n"
  }

  if ($secret_key != '') {
    validate_string($secret_key)
    $opt_secret_key = "sqs_aws_secret_key: ${secret_key}\n"
  }

  if ($region != '') {
    validate_string($region)
    $opt_region = "sqs_aws_region: ${region}\n"
  }

  if ($queue != '') {
    validate_string($queue)
    $opt_queue = "sqs_aws_queue: ${queue}\n"
  }

  #### Create file fragment

  file_fragment{"output_sqs_${::fqdn}":
    tag     => "beaver_config_${::fqdn}",
    content => "${opt_access_key}${opt_secret_key}${opt_region}${opt_queue}\n",
    order   => 20
  }

}
