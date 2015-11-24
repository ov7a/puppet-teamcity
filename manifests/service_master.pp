class teamcity::service_master inherits teamcity::params  {

  include systemd

  $start_command = 'teamcity-server.sh run'
  $stop_command  = 'teamcity-server.sh stop 30 -force'
  $kill_command  = 'teamcity-server.sh stop 5  -force'

  file { '/etc/systemd/system/teamcity.service':
    ensure  => 'present',
    content => template('teamcity/systemd_teamcity.service.erb'),
    mode    => '0755',
  } ~>

  Exec['systemctl-daemon-reload'] ->

  service { 'teamcity':
    ensure  => 'running',
    enable  => true,
  }

}