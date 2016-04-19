neutron:
  server:
    enabled: true
    plugin: opencontrail
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
      members:
      - host: 127.0.0.1
      - host: 127.0.1.1
      - host: 127.0.2.1
      user: openstack
      password: password
      virtual_host: '/openstack'
      ha_queues: true
    compute:
      host: 127.0.0.1
      region: RegionOne
      user: nova
      password: password
      tenant: service
