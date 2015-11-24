class teamcity::params (
  $teamcity_version               = '9.1.3',
  $teamcity_base_url             = 'http://download.jetbrains.com/teamcity/TeamCity-%%%VERSION%%%.tar.gz',

  $db_type                        = undef,
  $db_host                        = undef,
  $db_port                        = undef,
  $db_name                        = undef,
  $db_user                        = undef,
  $db_pass                        = undef,

  # unused
  $db_admin_user                  = undef,
  $db_admin_pass                  = undef,

  $jdbc_download_url              = undef,

  $teamcity_data_path             = '/var/lib/teamcity',
  $teamcity_logs_path             = '/opt/teamcity/logs',
) {
}