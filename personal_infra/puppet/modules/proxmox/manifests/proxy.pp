class proxmox::proxy ($mail, $base_hostname) {
  package {'apache2':}
  ->
  service {'apache2':
    enable => true,
    ensure => running,
    require => File['/usr/local/bin/notify_md_renewal'],
  }

  $apache_dep = {
    require => Package['apache2'],
    notify => Service['apache2'],
  }

  ['md', 'ssl', 'proxy_http', 'proxy'].each |$mod| {
    exec {"/usr/sbin/a2enmod $mod":
      creates => "/etc/apache2/mods-enabled/$mod.load",
      * => $apache_dep,
    }
  }

  file {'/etc/apache2/sites-enabled/test.conf':
    content => @("EOT")
    MDomain $base_hostname auto
    MDCertificateAgreement accepted
    MDContactEmail $mail
    MDNotifyCmd /usr/local/bin/notify_md_renewal

    <VirtualHost *:443>
      ServerName $base_hostname
      SSLEngine on
    </VirtualHost>
    | EOT
    ,
    * => $apache_dep
  }

  file {'/usr/local/bin/notify_md_renewal':
    content => @("EOT"/$)
    #!/bin/sh

    systemctl restart apache2
    pvenode cert set /etc/apache2/md/domains/$base_hostname/pubcert.pem /etc/apache2/md/domains/$base_hostname/privkey.pem  --force 1 --restart 1

    for hook in /usr/local/bin/notify_md_renewal_hook_* ; do
      \$hook
    done
    | EOT
    ,
    mode => '4755',
  }
}
