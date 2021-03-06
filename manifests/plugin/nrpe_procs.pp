# Export Nagios service for check_procs
class nagios::plugin::nrpe_procs (
  $warn                          = 500,
  $crit                          = 600,
  Integer $notification_interval = lookup('nagios::notification_interval'),
  String $notification_period    = lookup('nagios::notification_period')
){
  # Configure nrpe directories first
  include nrpe

# NRPE Command
  nrpe::command { 'check_procs_total':
    ensure  => present,
    command => "check_procs -w ${warn} -c ${crit}";
  }

# Nagios Check
  @@nagios_service { "check-procs_${::hostname}":
    check_command         => 'check_nrpe!check_procs_total',
    service_description   => 'Current Processes',
    host_name             => $::fqdn,
    notify                => Service['nagios'],
    tag                   => $::environment,
    notification_interval => $notification_interval,
    notification_period   => $notification_period,
    require               => Class['nagios'],
  }
}
