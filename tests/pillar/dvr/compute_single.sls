neutron:
  compute:
    enabled: true
    version: kilo
    mtu: 1500
    tunnel_type: gre
    distributed: true
    bind:
      address: 127.0.0.1
    database:
      engine: mysql
      host: 127.0.0.1
      port: 3306
      name: neutron
      user: neutron
      password: password
    identity:
      engine: keystone
      host: 127.0.0.1
      port: 35357
      user: neutron
      password: password
      tenant: service
    metadata:
      host: 127.0.0.1
      port: 8775
      password: metadataPass
    message_queue:
      engine: rabbitmq
      host: 127.0.0.1
      port: 5672
      user: openstack
      password: password
      virtual_host: '/openstack'
