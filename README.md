# puppet-teamcity

A module which installs JetBrains' TeamCity on a server.

Current limitations:

- only master supported
- only postgres as database supported


## Services

The module will install java (using `include java` and the `puppetlabs/java` module), then download and install teamcity including the postgres JDBC jar. It will also create a systemd service file.


## Tested on

- ubuntu 15.10


## Usage

    include teamcity::master

If you want to modify parameters (which you do, currently, cause you must set the database connection) you have to include the `teamcity::params` class like this:

    # teamcity::params class with default parameters
    class { 'teamcity::params':
        $teamcity_version               => '9.1.3',

        $teamcity_base_url              => 'http://download.jetbrains.com/teamcity/TeamCity-%%%VERSION%%%.tar.gz',

        $db_type                        => undef,
        $db_host                        => undef,
        $db_port                        => undef,
        $db_name                        => undef,
        $db_user                        => undef,
        $db_pass                        => undef,

        $jdbc_download_url              => undef,

        $teamcity_data_path             => '/var/lib/teamcity',
        $teamcity_logs_path             => '/opt/teamcity/logs',
    }
