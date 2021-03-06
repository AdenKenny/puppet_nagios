# Create a Nagios check that queries the last report status for a node from PuppetDB 
class nagios::puppetdb {

  # jq is required for JSON parsing
  package { 'jq':
    ensure   => 'installed',
    provider => 'yum',
  }

  # Deploy Nagios check script
  file { '/usr/lib64/nagios/plugins/check_puppetdb_state.sh':
    ensure  => 'file',
    mode    => '0755',
    content => epp('nagios/check_puppetdb_state.sh.epp'),
  }

  # Add command to $nagios::server::command_config
  nagios_command { 'check_puppetdb_status':
    ensure       => 'present',
    command_line => '/usr/lib64/nagios/plugins/check_puppetdb_state.sh $HOSTNAME$',
    notify       => Service['nagios'],
  }

  # Nagios needs root access to read the Puppet agent SSL files (in order to access the Puppet DB API)
  include sudo

  sudo::conf { 'nagios':
    content  => 'nagios  ALL=(ALL) NOPASSWD: /bin/curl',
    priority => 20
  }

  # Nagios needs access to files with context puppet_etc_t and cert_t to run the curl command
  selinux::module { 'allow_nagios_curl':
    ensure    => 'present',
    source_te => 'puppet:///modules/nagios/allow_nagios_curl.te',
  }

}
