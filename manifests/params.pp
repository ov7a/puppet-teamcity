class teamcity::params (
  $teamcity_version               = '9.1.3',
  $teamcity_base_url              = 'http://download.jetbrains.com/teamcity/TeamCity-%%%VERSION%%%.tar.gz',

  $add_agent_sudo                 = false,

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
  $agent_download_url             = '%%%TC_MASTER%%%/update/buildAgent.zip',
  $agent_master_url               = undef,

  $teamcity_agent_path            = '/opt/teamcity_agent',
  $teamcity_data_path             = '/var/lib/teamcity',
  $teamcity_logs_path             = '/opt/teamcity/logs',

  $archive_provider               = 'camptocamp',

) {

  validate_re($archive_provider, '^(camptocamp|puppet)$',
    "teamcity::params::archive_provider must be one of 'camptocamp'/'puppet'"
  )

}
