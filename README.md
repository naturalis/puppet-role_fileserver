puppet-role_fileserver
==================

Fileserver role manifest for puppet in a foreman environment.

Parameters
-------------
All parameters are read from defaults in init.pp and can be overwritten by hiera or The foreman


```
  $workgroup            = 'DOMAIN',
  $valid_users          = '@DOMAIN\"Domain Admins"',
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
  $volume_size          = '2048',               ' volume size in GB
  $volume_name,                                 ' unique volume name

```


Classes
-------------
role_fileserver

Dependencies
-------------
naturalis/puppet-novatools
naturalis/puppet-samba


Result
-------------
Samba fileserver with active directory integration, will become members server within domain. The /data directory will be supplied by a created or mounted openstack volume.


Limitations
-------------
This module has been built on and tested against Puppet 3 and higher.

The module has been tested on:
- Ubuntu 14.04LTS 


Authors
-------------
Author Name <hugo.vanduijn@naturalis.nl>