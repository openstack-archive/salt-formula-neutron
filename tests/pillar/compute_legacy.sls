neutron:
  compute:
    agent_mode: legacy
    backend:
      engine: ml2
      mechanism:
        ovs:
          driver: openvswitch
    dvr: false
    enabled: true
    external_access: false
    local_ip: 10.1.0.105
    message_queue:
      engine: rabbitmq
      host: 172.16.10.254
      password: workshop
      port: 5672
      user: openstack
      virtual_host: /openstack
    metadata:
      host: 172.16.10.254
      password: password
    version: mitaka
