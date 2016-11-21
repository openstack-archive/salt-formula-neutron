neutron:
  gateway:
    agent_mode: dvr_snat
    backend:
      engine: ml2
      mechanism:
        ovs:
          driver: openvswitch
    dvr: true
    enabled: true
    external_access: True
    local_ip: 10.1.0.110
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