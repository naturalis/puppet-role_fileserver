class role_fileserver (
  $workgroup            = 'DOMAIN',
  $server_string        = 'Example Samba Server',
  $interfaces           = 'eth0 lo',
  $security             = 'ads',
  $sharename            = 'samba-share',
  $sharecomment         = 'testshare',
  $path                 = '/data',
  $read_only            = false,
  $target_ou            = "Computers",
  $nsswitch             = true,
  $winbindaccount       = 'DomainAdmin',
  $winbindpassword      = 'DomainAdminPass',
  $winbindrealm         = 'DOMAIN',
  $load_printers        = 'No',
  $disable_spoolss      = 'Yes',
  $printing             = 'bsd',
  $printcap_name        = '/dev/null',
  $mount_point          = '/data',
  $controller_ip        = '10.41.1.1',
  $openstack_username   = 'fileservers',
  $openstack_tentant    = 'fileservers',
  $password             = 'password',
  $volume_size          = '2048',
  $volume_name,
  $public_ip            = undef,
  ){

  package { 'python-novaclient':
    ensure => present,
  }

  file { $path :
    ensure         => 'directory'
  } 

  if ($public_ip){
    exec { 'updateDNS':
      command      => "net ads dns register ${fqdn} ${public_ip} -P",
      path         => "/usr/local/bin/:/bin/:/usr/bin",
      unless       => "host ${fqdn} | grep -c ${public_ip}",
      require      => Class['samba::server::ads']

    }
  }

  nova_volume_create { $volume_name :
    ensure         => present,
    password       => $password,
    username       => $openstack_username,
    tenant         => $openstack_tentant,
    controller_ip  => $controller_ip,
    volume_size    => $volume_size,
    require        => Package['python-novaclient'],
  }

  nova_volume_attach { $volume_name :
    ensure         => present,
    password       => $password,
    username       => $openstack_username,
    tenant         => $openstack_tentant,
    controller_ip  => $controller_ip,
    instance       => $::fqdn,
    require        => Nova_volume_create[$volume_name],
  }

  nova_volume_mount { $volume_name :
    ensure         => present,
    password       => $password,
    username       => $openstack_username,
    tenant         => $openstack_tentant,
    controller_ip  => $controller_ip,
    instance       => $::fqdn,
    mountpoint     => $mount_point,
    filesystem     => 'ext4',
    mount_options  => 'user_xattr,acl',
    require        => [Nova_volume_attach[$volume_name],File[$path]]
  }

  class {'samba::server':
    workgroup           => $workgroup,
    server_string       => $server_string,
    interfaces          => $interfaces,
    security            => $security,
    load_printers       => $load_printers,
    disable_spoolss     => $disable_spoolss,
    printing            => $printing,
    printcap_name       => $printcap_name,
  }

  samba::server::share {$sharename:
    comment           => $sharecomment,
    path              => $path,
    read_only         => $read_only,
  }

  if $security == 'ads' {
    class { 'samba::server::ads':
      winbind_acct    => $winbindaccount,
      winbind_pass    => $winbindpassword,
      realm           => $winbindrealm,
      nsswitch        => $nsswitch,
      target_ou       => $target_ou
    }
  }
}