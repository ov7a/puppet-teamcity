class teamcity::install inherits teamcity::params  {

  # taken from params

  $teamcity_version               = $teamcity::params::teamcity_version
  $teamcity_base_url              = $teamcity::params::teamcity_base_url

  $db_type                        = $teamcity::params::db_type
  $jdbc_download_url              = $teamcity::params::jdbc_download_url

  $teamcity_data_path             = $teamcity::params::teamcity_data_path
  $teamcity_logs_path             = $teamcity::params::teamcity_logs_path

  # derived

  $use_download_url = regsubst($teamcity_base_url, '%%%VERSION%%%', $teamcity_version)
  $use_target_dir   = "/opt/teamcity-${teamcity_version}"
  $tmp              = split($jdbc_download_postgres, "[/\\\\]")
  $jdbc_filename    = $tmp[-1]

  $use_jdbc_download_url = $jdbc_download ? {
    undef => $db_type ? {
      'postgresql'  => 'https://jdbc.postgresql.org/download/postgresql-9.4-1205.jdbc41.jar',
    },
    default => $jdbc_download_url,
  }

  include wget
  include java
  include systemd
  Class['java'] -> Group['teamcity']


  group { 'teamcity':
    ensure  => 'present',
    gid     => '2158',
  } ->

  user { 'teamcity':
    ensure  => 'present',
    gid     => 'teamcity',
    uid     => '2158',
  }

  file { ["/opt/teamcity-${teamcity_version}",'/opt/teamcity-sources']:
    ensure  => 'directory',
    owner   => 'teamcity',
    group   => 'teamcity',
  } ->

  file { "/opt/teamcity":
    ensure  => 'link',
    target  => "/opt/teamcity-${teamcity_version}",
  } ->

  archive { "teamcity-${teamcity_version}":
    ensure            => 'present',
    url               => $use_download_url,
    target            => $use_target_dir,
    src_target        => '/opt/teamcity-sources',
    follow_redirects  => true,
    checksum          => false,
    strip_components  => 1,
    user              => 'teamcity',
  } ->

  file { [
    "${teamcity_data_path}",
    "${teamcity_data_path}/config",
    "${teamcity_data_path}/lib",
    "${teamcity_data_path}/lib/jdbc"]:
    ensure  => 'directory',
    owner   => 'teamcity',
    group   => 'teamcity',
  } ->

  wget::fetch { $use_jdbc_download_url:
    destination => "${teamcity_data_path}/lib/jdbc/${jdbc_filename}",
    user        => 'teamcity',
  }

}