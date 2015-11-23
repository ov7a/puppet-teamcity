class teamcity::service_master inherits teamcity::params  {

  $start_command = 'start-server'

  file { '/etc/systemd/system/teamcity.service':
    ensure  => 'present',
    content => template('profiles/systemd_teamcity.service.erb'),
    mode    => '0755',
  } ~>

  Exec['systemctl-daemon-reload']

  service { 'teamcity':
    ensure  => 'running',
    enable  => true,
  }

}