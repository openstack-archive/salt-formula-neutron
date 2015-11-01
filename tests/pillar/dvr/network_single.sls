neutron:
  network:
    enabled: true
    version: kilo
    tunnel_type: gre
    mtu: 1500
    distributed: true
    bind:
      address: 127.0.0.1
    metadata:
      host: 127.0.0.1
      port: 8775
      password: metadataPass
    identity:
      engine: keystone
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
