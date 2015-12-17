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
  $disable_osprober     = false,
  ){

  package { 'python-novaclient':
    ensure => present,
  }

  file { $path :
    ensure         => 'directory'
  } 

  if ($disable_osprober == true){
    file { '/usr/bin/os-prober':
      ensure         => 'file',
      mode           => '0640'
    }
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