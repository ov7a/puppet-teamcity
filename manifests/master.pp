class teamcity::master inherits teamcity::params {

  include teamcity::install
  include teamcity::config
  include teamcity::service_master

  Class['teamcity::install'] ->
  Class['teamcity::config'] ->
  Class['teamcity::service_master']

}
