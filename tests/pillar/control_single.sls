neutron:
  server:
    enabled: true
    backend:
      engine: contrail
      host: contrail_discovery_host
      port: 8082
      user: admin
      password: password
      tenant: admin
      token: token
    fwaas: false
    dns_domain: novalocal
    tunnel_type: vxlan
    version: liberty
    bind:
      address: 127.0.0.1
      port: 9696
    database:
      engine: mysql
      host: 127.0.0.1
      port: 3306
      name: neutron
      user: neutron
      password: password
    identity:
      engine: keystone
      region: RegionOne
      host: 127.0.0.1
      port: 35357
      user: neutron
      password: password
      tenant: service
    message_queue:
      engine: rabbitmq
      host: 127.0.0.1
      port: 5672
      user: openstack
      password: password
      virtual_host: '/openstack'
    compute:
      host: 127.0.0.1
      region: RegionOne
      user: nova
      password: password
      tenant: service
