=======================
Neutron Network Service
=======================

Neutron is an OpenStack project to provide "networking as a service" between
interface devices (e.g., vNICs) managed by other Openstack services (e.g.,
nova).

Starting in the Folsom release, Neutron is a core and supported part of the
OpenStack platform (for Essex, we were an "incubated" project, which means use
is suggested only for those who really know what they're doing with Neutron). 

Usage notes
===========

For live migration to work, you have to set migration param on bridge and
switch nodes.

.. code-block:: yaml

    neutron:
      bridge:
        enabled: true
        migration: true

.. code-block:: yaml

    neutron:
      switch:
        enabled: true
        migration: true

Furthermore you need to set private and public keys for user 'neutron'.

Sample pillars
==============

Neutron Server on the controller node

.. code-block:: yaml

    neutron:
      server:
        enabled: true
        version: havana
        plugin: ml2/contrail
        bind:
          address: 172.20.0.1
          port: 9696
        tunnel_type: vxlan
        public_networks:
        - name: public
          subnets:
          - name: public-subnet
            gateway: 10.0.0.1
            network: 10.0.0.0/24
            pool_start: 10.0.5.20
            pool_end: 10.0.5.200
            dhcp: False
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
        fwaas: false

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
