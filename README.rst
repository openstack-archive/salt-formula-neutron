=======================
Neutron Network Service
=======================

Neutron is an OpenStack project to provide "networking as a service" between
interface devices (e.g., vNICs) managed by other Openstack services (e.g.,
nova).

Starting in the Folsom release, Neutron is a core and supported part of the
OpenStack platform (for Essex, we were an "incubated" project, which means use
is suggested only for those who really know what they're doing with Neutron). 

Sample pillars
==============

Neutron Server on the controller node

.. code-block:: yaml

    neutron:
      server:
        enabled: true
        version: mitaka
        bind:
          address: 172.20.0.1
          port: 9696
        database:
          engine: mysql
          host: 127.0.0.1
          port: 3306
          name: neutron
          user: neutron
          password: pwd
        identity:
          engine: keystone
          host: 127.0.0.1
          port: 35357
          user: neutron
          password: pwd
          tenant: service
        message_queue:
          engine: rabbitmq
          host: 127.0.0.1
          port: 5672
          user: openstack
          password: pwd
          virtual_host: '/openstack'
        metadata:
          host: 127.0.0.1
          port: 8775
          password: pass

Neutron VXLAN tenant networks with Network Nodes (with DVR for East-West
 and Network node for North-South)
=========================================================================
===================================

This use case describes a model utilising VxLAN overlay with DVR. The DVR
 routers will only be utilized for traffic that is router within the cloud
  infrastructure and that remains encapsulated. External traffic will be 
  routed to via the network nodes. 

The intention is that each tenant will require at least two (2) vrouters 
one to be utilised 

Neutron Server only
-------------------

.. code-block:: yaml

    neutron:
      server:
        version: mitaka
        bind:
          address: 172.20.0.1
          port: 9696
        database:
          engine: mysql
          host: 127.0.0.1
          port: 3306
          name: neutron
          user: neutron
          password: pwd
        identity:
          engine: keystone
          host: 127.0.0.1
          port: 35357
          user: neutron
          password: pwd
          tenant: service
        message_queue:
          engine: rabbitmq
          host: 127.0.0.1
          port: 5672
          user: openstack
          password: pwd
          virtual_host: '/openstack'
        global_physnet_mtu: 9000
        l3_ha: True
        dvr: True #disabled for non DVR use case
        backend:
          engine: ml2
          tenant_network_types= "flat,vxlan"
          external_mtu: 9000
          mechanism:
            ovs:
              driver: openvswitch

Network Node only
-----------------

.. code-block:: yaml

    neutron:
      gateway:
        enabled: True
        version: mitaka
        message_queue:
          engine: rabbitmq
          host: 127.0.0.1
          port: 5672
          user: openstack
          password: pwd
          virtual_host: '/openstack'
        local_ip: 192.168.20.20 # br-mesh ip address
        dvr: True # disabled for non DVR use case
        agent_mode: dvr_snat
        metadata:
          host: 127.0.0.1
          password: pass
        backend:
          engine: ml2
          mechanism:
            ovs:
              driver: openvswitch  

Compute Node
-------------

.. code-block:: yaml

    neutron:
      compute:
        enabled: True
        version: mitaka
        message_queue:
          engine: rabbitmq
          host: 127.0.0.1
          port: 5672
          user: openstack
          password: pwd
          virtual_host: '/openstack'
        local_ip: 192.168.20.20 # br-mesh ip address
        dvr: True # disabled for non DVR use case
        agent_mode: dvr
        external_access: false # Compute node with DVR for east-west only, Network Node has True as default
        metadata:
          host: 127.0.0.1
          password: pass       
        backend:
          engine: ml2
          mechanism:
            ovs:
              driver: openvswitch

Neutron VXLAN tenant networks with Network Nodes (non DVR)
==========================================================

This section describes a network solution that utilises VxLAN overlay
 networks without DVR with all routers being managed on the network nodes.

Neutron Server only
-------------------

.. code-block:: yaml

    neutron:
      server:
        version: mitaka
        bind:
          address: 172.20.0.1
          port: 9696
        database:
          engine: mysql
          host: 127.0.0.1
          port: 3306
          name: neutron
          user: neutron
          password: pwd
        identity:
          engine: keystone
          host: 127.0.0.1
          port: 35357
          user: neutron
          password: pwd
          tenant: service
        message_queue:
          engine: rabbitmq
          host: 127.0.0.1
          port: 5672
          user: openstack
          password: pwd
          virtual_host: '/openstack'
        global_physnet_mtu: 9000
        l3_ha: True
        dvr: False
        backend:
          engine: ml2
          tenant_network_types= "flat,vxlan"
          external_mtu: 9000
          mechanism:
            ovs:
              driver: openvswitch

Network Node only
-----------------

.. code-block:: yaml

    neutron:
      gateway:
        enabled: True
        version: mitaka
        message_queue:
          engine: rabbitmq
          host: 127.0.0.1
          port: 5672
          user: openstack
          password: pwd
          virtual_host: '/openstack'
        local_ip: 192.168.20.20 # br-mesh ip address
        dvr: False
        agent_mode: legacy
        metadata:
          host: 127.0.0.1
          password: pass
        backend:
          engine: ml2
          mechanism:
            ovs:
              driver: openvswitch  

Compute Node
-------------

.. code-block:: yaml

    neutron:
      compute:
        enabled: True
        version: mitaka
        message_queue:
          engine: rabbitmq
          host: 127.0.0.1
          port: 5672
          user: openstack
          password: pwd
          virtual_host: '/openstack'
        local_ip: 192.168.20.20 # br-mesh ip address
        dvr: False      
        backend:
          engine: ml2
          mechanism:
            ovs:
              driver: openvswitch

Neutron VXLAN tenant networks with Network Nodes (with DVR for 
East-West and North-South Network node for SNAT)
==============================================================
========================================================

This section describes a network solution that utilises VxLAN 
overlay networks with DVR with North-South and East-West. Network 
Node is used only for SNAT.

Neutron Server only
-------------------

.. code-block:: yaml

    neutron:
      server:
        version: mitaka
        bind:
          address: 172.20.0.1
          port: 9696
        database:
          engine: mysql
          host: 127.0.0.1
          port: 3306
          name: neutron
          user: neutron
          password: pwd
        identity:
          engine: keystone
          host: 127.0.0.1
          port: 35357
          user: neutron
          password: pwd
          tenant: service
        message_queue:
          engine: rabbitmq
          host: 127.0.0.1
          port: 5672
          user: openstack
          password: pwd
          virtual_host: '/openstack'
        global_physnet_mtu: 9000
        l3_ha: False
        dvr: True
        backend:
          engine: ml2
          tenant_network_types= "flat,vxlan"
          external_mtu: 9000
          mechanism:
            ovs:
              driver: openvswitch

Network Node only
-----------------

.. code-block:: yaml

    neutron:
      gateway:
        enabled: True
        version: mitaka
        message_queue:
          engine: rabbitmq
          host: 127.0.0.1
          port: 5672
          user: openstack
          password: pwd
          virtual_host: '/openstack'
        local_ip: 192.168.20.20 # br-mesh ip address
        dvr: True
        agent_mode: dvr_snat
        metadata:
          host: 127.0.0.1
          password: pass
        backend:
          engine: ml2
          mechanism:
            ovs:
              driver: openvswitch  

Compute Node
-------------

.. code-block:: yaml

    neutron:
      compute:
        enabled: True
        version: mitaka
        message_queue:
          engine: rabbitmq
          host: 127.0.0.1
          port: 5672
          user: openstack
          password: pwd
          virtual_host: '/openstack'
        local_ip: 192.168.20.20 # br-mesh ip address
        dvr: True
        external_access: True     
        agent_mode: dvr
        metadata:
          host: 127.0.0.1
          password: pass
        backend:
          engine: ml2
          mechanism:
            ovs:
              driver: openvswitch

Neutron Server with OpenContrail
==================================

.. code-block:: yaml

    neutron:
      server:
        backend:
          engine: contrail
          host: contrail_discovery_host
          port: 8082
          user: admin
          password: password
          tenant: admin
          token: token

Neutron Server with Midonet
===========================

.. code-block:: yaml

    neutron:
      server:
        backend:
          engine: midonet
          host: midonet_api_host
          port: 8181
          user: admin
          password: password

Neutron bridge on the network node

.. code-block:: yaml

    neutron:
      bridge:
        enabled: true
        version: havana
        tunnel_type: vxlan
        bind:
          address: 172.20.0.2
        database:
          engine: mysql
          host: 127.0.0.1
          port: 3306
          name: neutron
          user: neutron
          password: pwd
        identity:
          engine: keystone
          host: 127.0.0.1
          port: 35357
          user: neutron
          password: pwd
          tenant: service
        message_queue:
          engine: rabbitmq
          host: 127.0.0.1
          port: 5672
          user: openstack
          password: pwd
          virtual_host: '/openstack'

Neutron switch on the compute node with live migration turned on

.. code-block:: yaml

    neutron:
      switch:
        enabled: true
        version: havana
        migration: True
        tunnel_type: vxlan
        bind:
          address: 127.20.0.100
        database:
          engine: mysql
          host: 127.0.0.1
          port: 3306
          name: neutron
          user: neutron
          password: pwd
        identity:
          engine: keystone
          host: 127.0.0.1
          port: 35357
          user: neutron
          password: pwd
          tenant: service
        message_queue:
          engine: rabbitmq
          host: 127.0.0.1
          port: 5672
          user: openstack
          password: pwd
          virtual_host: '/openstack'

Neutron Keystone region

.. code-block:: yaml

    neutron:
      server:
        enabled: true
        version: kilo
        ...
        identity:
          region: RegionTwo
        ...
        compute:
          region: RegionTwo
        ...


Client-side RabbitMQ HA setup

.. code-block:: yaml

    neutron:
      server:
        ....
        message_queue:
          engine: rabbitmq
          members:
            - host: 10.0.16.1
            - host: 10.0.16.2
            - host: 10.0.16.3
          user: openstack
          password: pwd
          virtual_host: '/openstack'
        ....



Usage
=====

Fix RDO Neutron installation

.. code-block:: yaml

    neutron-db-manage --config-file /usr/share/neutron/neutron-dist.conf --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugin.ini stamp havana

Documentation and Bugs
============================

To learn how to deploy OpenStack Salt, consult the documentation available
online at:

    https://wiki.openstack.org/wiki/OpenStackSalt

In the unfortunate event that bugs are discovered, they should be reported to
the appropriate bug tracker. If you obtained the software from a 3rd party
operating system vendor, it is often wise to use their own bug tracker for
reporting problems. In all other cases use the master OpenStack bug tracker,
available at:

    http://bugs.launchpad.net/openstack-salt

Developers wishing to work on the OpenStack Salt project should always base
their work on the latest formulas code, available from the master GIT
repository at:

    https://git.openstack.org/cgit/openstack/salt-formula-neutron

Developers should also join the discussion on the IRC list, at:

    https://wiki.openstack.org/wiki/Meetings/openstack-salt
