# == Class: role_fileserver::docker
#
# === Authors
#
# Author Name <hugo.vanduijn@naturalis.nl>
#
# === Copyright
#
# Apache2 license 2017.
#
class role_fileserver::docker (
  $compose_version              = '1.17.1',
  $repo_source                  = 'https://github.com/naturalis/docker-samba.git',
  $repo_ensure                  = 'latest',
  $repo_dir                     = '/opt/docker-samba',
  $smb_share                    = 'data',
  $smb_user                     = 'smbuser',
  $smb_password                 = 'password',
  $smb_workgroup                = 'samba',
  $git_branch                   = 'master',
){

  include 'docker'
  include 'stdlib'

  Exec {
    path => '/usr/local/bin/',
    cwd  => $role_fileserver::docker::repo_dir,
  }

  file { ['/data'] :
    ensure              => directory,
    require             => Class['docker'],
  }

  file { $role_fileserver::docker::repo_dir:
    ensure              => directory,
    mode                => '0770',
  }


  file { "${role_fileserver::docker::repo_dir}/.env":
    ensure   => file,
    mode     => '0600',
    content  => template('role_fileserver/env.erb'),
    require  => Vcsrepo[$role_fileserver::docker::repo_dir],
    notify   => Exec['Restart containers on change'],
  }

  class {'docker::compose': 
    ensure      => present,
    version     => $role_fileserver::docker::compose_version,
    notify      => Exec['apt_update']
  }

#  docker_network { 'web':
#    ensure   => present,
#  }

  ensure_packages(['git','python3'], { ensure => 'present' })

  vcsrepo { $role_fileserver::docker::repo_dir:
    ensure    => $role_fileserver::docker::repo_ensure,
    source    => $role_fileserver::docker::repo_source,
    provider  => 'git',
    user      => 'root',
    revision  => 'master',
    require   => [Package['git'],File[$role_fileserver::docker::repo_dir]]
  }

  docker_compose { "${role_fileserver::docker::repo_dir}/docker-compose.yml":
    ensure      => present,
    require     => [
      Vcsrepo[$role_fileserver::docker::repo_dir],
      File["${role_fileserver::docker::repo_dir}/.env"]
    ]
  }

# no option for fixed versions in current samba container so no automatic pulls...

#  exec { 'Pull containers' :
#    command  => 'docker-compose pull',
#    schedule => 'everyday',
#  }

#  exec { 'Up the containers to resolve updates' :
#    command  => 'docker-compose up -d',
#    schedule => 'everyday',
#    require  => Exec['Pull containers']
#  }

  exec {'Restart containers on change':
    refreshonly => true,
    command     => 'docker-compose up -d',
    require     => Docker_compose["${role_fileserver::docker::repo_dir}/docker-compose.yml"]
  }

  # deze gaat per dag 1 keer checken
  # je kan ook een range aan geven, bv tussen 7 en 9 's ochtends
#  schedule { 'everyday':
#     period  => daily,
#     repeat  => 1,
#     range => '5-7',
#  }

}
