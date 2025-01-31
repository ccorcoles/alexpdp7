node 'h1.pdp7.net' {
  class {'proxmox::freeipa':}
  class {'dns_dhcp':}

  class {'backups':
    sanoid_config =>  @("EOT")
      # pg data
      [rpool/data/subvol-204-disk-1]
        use_template = backup

      # nextcloud
      [rpool/data/subvol-208-disk-1]
        use_template = backup

      # bitwarden
      [rpool/data/subvol-210-disk-1]
        use_template = backup

      [template_backup]
        frequently=0
        hourly=0
        daily=100000
        monthly=0
        yearly=0
        autosnap=yes
      | EOT
    ,
  }

  # TODO: ugly; tinc scripts require this :(
  package {'net-tools':}

  # https://lists.fedorahosted.org/archives/list/freeipa-users@lists.fedorahosted.org/thread/EZSM6LQPSNRY4WA52IYVR46RSXIDU3U7/
  # SSH hack
  file {'/etc/ssh/sshd_config.d/weak-gss.conf':
    content => "GSSAPIStrictAcceptorCheck no\n",
  }
  ~>
  service {'sshd':}

  class {'proxmox::proxy':
    mail => lookup('mail.root_mail'),
    base_hostname => lookup('network.public_hostname'),
  }

  proxmox::proxy_host {'idp.pdp7.net':
    target => 'https://ipsilon.h1.int.pdp7.net/',
    overwrite_rh_certs => 'ipsilon.h1.int.pdp7.net',
  }

  proxmox::proxy_host {'weight.pdp7.net':
    target => 'https://k8s-prod.h1.int.pdp7.net/',
  }

  proxmox::proxy_host {'alex.corcoles.net':
    target => 'https://k8s-prod.h1.int.pdp7.net/',
  }

  proxmox::proxy_host {'miniflux.pdp7.net':
    target => 'http://miniflux.h1.int.pdp7.net:8080/',
  }

  proxmox::proxy_host {'nextcloud.pdp7.net':
    target => 'http://nextcloud.h1.int.pdp7.net/',
  }

  proxmox::proxy_host {'bitwarden.pdp7.net':
    target => 'http://bitwarden.h1.int.pdp7.net:8000/',
  }

  proxmox::proxy_host {'grafana.pdp7.net':
    target => 'http://grafana.h1.int.pdp7.net:3000/',
  }

  package {'haproxy':}
  ->
  file {'/etc/haproxy/haproxy.cfg':
    content =>  @("EOT")
      global
              log /dev/log	local0
              log /dev/log	local1 notice
              chroot /var/lib/haproxy
              stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
              stats timeout 30s
              user haproxy
              group haproxy
              daemon

              # Default SSL material locations
              ca-base /etc/ssl/certs
              crt-base /etc/ssl/private

              # See: https://ssl-config.mozilla.org/#server=haproxy&server-version=2.0.3&config=intermediate
              ssl-default-bind-ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384
              ssl-default-bind-ciphersuites TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256
              ssl-default-bind-options ssl-min-ver TLSv1.2 no-tls-tickets

      defaults
              log	global
              mode	http
              option	httplog
              option	dontlognull
              timeout connect 5000
              timeout client  50000
              timeout server  50000
              errorfile 400 /etc/haproxy/errors/400.http
              errorfile 403 /etc/haproxy/errors/403.http
              errorfile 408 /etc/haproxy/errors/408.http
              errorfile 500 /etc/haproxy/errors/500.http
              errorfile 502 /etc/haproxy/errors/502.http
              errorfile 503 /etc/haproxy/errors/503.http
              errorfile 504 /etc/haproxy/errors/504.http

      frontend gemini
              bind :1965
              mode tcp
              option tcplog
              default_backend blog
              # TODO: sni
              # tcp-request inspect-delay 5s
              # acl blog req_ssl_sni blog.pdp7.net
              # use_backend blog if blog

      backend blog
              mode tcp
              server blog k8s-prod.h1.int.pdp7.net:31965
      | EOT
    ,
  }
  ~>
  service {'haproxy':
    enable => true,
    ensure => running,
  }
}
