# puppet-beaver

A puppet module for managing and configuring Beaver

This module is puppet 3 tested

## Usage

Installation, make sure service is running and will be started at boot time:

     class { 'beaver': }

Removal/decommissioning:

     class { 'beaver':
       ensure => 'absent',
     }

Install everything but disable service(s) afterwards:

     class { 'beaver':
       status => 'disabled',
     }

### Inputs

At this moment there is only the file input.

     beaver::input::file{ 'apache_access':
       file => '/var/log/apache/access.log',
       type => 'apache-access'
     }

### Outputs

Use 1 of the following outputs:

     beaver::output::redis{'redisout':
       host => 'redishost'
     }

     beaver::output::zeromq{ 'zeromqout':
       host => 'zeromqhost',
       type => 'connect'
     }

     beaver::output::rabbitmq { 'rabbitmq_output':
       host => 'rabbitmqhost'
     }

     beaver::output::udp{ 'udpout':
       host => 'udphost'
       port => 9999
     }
