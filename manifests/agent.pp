define teamcity::agent (
  $master_url = undef,
  $port       = '9090',
) {

  include teamcity::params
  Class['teamcity::params'] -> Teamcity::Agent<||>

  include teamcity::agent::sudo

  # first, try to get it from the parameters class
  $use_master_url = $master_url ? {
    undef   => $::teamcity::params::agent_master_url,
    default => $master_url,
  }

  # ... then from hiera directly.
  #$use_master_url = $tmp ? {
  #  undef   => hiera('teamcity::params::master_url', undef),
  #  default => undef,
  #}

  if $use_master_url == undef {
    fail("Teamcity::Agent[${title}]: Please set \$master_url or teamcity::param::agent_master_url")
  }


  # necessary includes

  include java
  include teamcity::prepare
  include systemd


  # install

  $tc_agent_path    = $::teamcity::params::teamcity_agent_path
  $download_url     = $::teamcity::params::agent_download_url
  $use_download_url = regsubst($download_url, '%%%TC_MASTER%%%', $use_master_url)
  $use_agent_path   = "${tc_agent_path}_${title}"

  mkdir::p { $use_agent_path :
    owner => 'teamcity',
    group => 'teamcity',
  } ->

  archive { "teamcity-agent-${title}":
    ensure            => 'present',
    url               => $use_download_url,
    target            => $use_agent_path,
    src_target        => '/opt/teamcity-sources',
    follow_redirects  => true,
    checksum          => false,
    user              => 'teamcity',
    extension         => 'zip',
  } ->

  exec { "check agents' ${title} presence":
    command => 'false',
    unless  => "test -f '${use_agent_path}/bin/agent.sh'",
    path    => '/usr/bin:/bin',
  } ->

  # yup, not done in the zip distribution. yeah, great.
  file { "${use_agent_path}/bin/agent.sh":
    ensure  => 'present',
    mode    => '0755',
  } ->


  # config

  exec { "create agent ${title} buildAgent.dist":
    command   => 'cp buildAgent.dist.properties buildAgent.properties',
    cwd       => "${use_agent_path}/conf",
    path      => '/usr/bin:/bin',
    unless    => 'test -f buildAgent.properties',
    user      => 'teamcity',
  } ->

  file_line { "agent ${title} server url":
    ensure  => 'present',
    path    => "${use_agent_path}/conf/buildAgent.properties",
    line    => "serverUrl=${use_master_url}",
    match   => '^ *#? *serverUrl *=.*',
  } ->

  file_line { "agent ${title} own port":
    ensure  => 'present',
    path    => "${use_agent_path}/conf/buildAgent.properties",
    line    => "ownPort=${port}",
    match   => '^ *#? *ownPort *=.*',
  } ->

  file_line { "agent ${title} own name":
    ensure  => 'present',
    path    => "${use_agent_path}/conf/buildAgent.properties",
    line    => "name=${title}",
    match   => '^ *#? *name *=.*',
    before  => Service["teamcity-agent-${title}"],
  }


  # service

  $start_command        = "${use_agent_path}/bin/agent.sh run"
  $stop_command         = "${use_agent_path}/bin/agent.sh stop"
  $kill_command         = "${use_agent_path}/bin/agent.sh stop force"
  $service_description  = "Teamcity build agent '${title}'"

  file { "/etc/systemd/system/teamcity-agent-${title}.service":
    ensure  => 'present',
    content => template('teamcity/systemd_teamcity.service.erb'),
    mode    => '0755',
  } ~>

  Exec['systemctl-daemon-reload'] ->

  service { "teamcity-agent-${title}":
    ensure  => 'running',
    enable  => true,
    require => File["${use_agent_path}/bin/agent.sh"]
  }

}
