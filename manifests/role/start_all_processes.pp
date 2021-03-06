class dynatrace::role::start_all_processes (
  $ensure                  = 'present',
  $role_name               = 'Dynatrace Server start all services',
  $installer_bitsize       = $dynatrace::server_installer_bitsize,
  $installer_prefix_dir    = $dynatrace::server_installer_prefix_dir,
  $installer_file_name     = $dynatrace::server_installer_file_name,
  $installer_file_url      = $dynatrace::server_installer_file_url,
  $license_file_name       = $dynatrace::server_license_file_name,
  $license_file_url        = $dynatrace::server_license_file_url,
  $collector_port          = $dynatrace::server_collector_port,
  $pwh_connection_hostname = $dynatrace::server_pwh_connection_hostname,
  $pwh_connection_port     = $dynatrace::server_pwh_connection_port,
  $pwh_connection_dbms     = $dynatrace::server_pwh_connection_dbms,
  $pwh_connection_database = $dynatrace::server_pwh_connection_database,
  $pwh_connection_username = $dynatrace::server_pwh_connection_username,
  $pwh_connection_password = $dynatrace::server_pwh_connection_password,
  $dynatrace_owner         = $dynatrace::dynatrace_owner,
  $dynatrace_group         = $dynatrace::dynatrace_group
) inherits dynatrace {

  case $::kernel {
    'Linux': {
      $services_to_start_array = [
        $dynatrace::dynaTraceServer,
        $dynatrace::dynaTraceCollector,
        $dynatrace::dynaTraceAnalysis,
        $dynatrace::dynaTraceWebServerAgent,
        $dynatrace::dynaTraceHostagent,
#        'dynaTraceBackendServer',
#        'dynaTraceFrontendServer'
        ]
    }
    default: {}
  }

  $services_to_start_array.each |$x| {
#    if ("test -L /etc/init.d/${x}") {
#      notify {"Service ${x} exists and will be stopped.": }
#    }
#
#    #TODO cannot use service resource because of duplicated name in stop_all_processes
#    service { "${role_name}: Service ${x} exists and will be started.":
#      title  => "start_all_processes ${x}",
#      ensure => 'running',
#      name   => $x,
#      enable => true
#    }

#    puts "Start the service: '${x}'"

    exec {"Start the service: '${x}'":    #hack to ensure restart service (stop service then start it) [there is no possibility in puppet to use the same name of service in different stauses because of error 'Cannot alias Service']
      command => "service ${x} start",
      path    => ['/usr/bin', '/usr/sbin', '/bin', '/sbin'],
      onlyif  => ["test -L /etc/init.d/${x}"],
    }
  }

  if $collector_port != '6699' {
    wait_until_port_is_open { '6699':
      ensure  => $ensure,
    }
  }

  wait_until_port_is_open { $collector_port:
    ensure  => $ensure,
  } ->

  wait_until_port_is_open { '2021':
    ensure  => $ensure,
  } ->

  wait_until_port_is_open { '8021':
    ensure  => $ensure,
  }

}
