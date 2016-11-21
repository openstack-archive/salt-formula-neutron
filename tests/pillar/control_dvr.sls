neutron:
  server:
    backend:
      engine: ml2
      external_mtu: 1500
      mechanism:
        ovs:
          driver: openvswitch
      tenant_network_types: flat,vxlan
    bind:
      address: 172.16.10.101
      port: 9696
    compute:
      host: 172.16.10.254
      password: workshop
      region: RegionOne
      tenant: service
      user: nova
    database:
      engine: mysql
      host: 172.16.10.254
      name: neutron
      password: workshop
      port: 3306
      user: neutron
    dns_domain: novalocal
    dvr: true
    enabled: true
    global_physnet_mtu: 1500
    identity:
      engine: keystone
      host: 172.16.10.254
      password: workshop
      port: 35357
      region: RegionOne
      tenant: service
      user: neutron
    l3_ha: false
    message_queue:
      engine: rabbitmq
      host: 172.16.10.254
      password: workshop
      port: 5672
      user: openstack
      virtual_host: /openstack
    plugin: ml2
    version: mitaka