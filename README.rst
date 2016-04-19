=======================
Neutron Network Service
=======================

Neutron is an OpenStack project to provide "networking as a service" between interface devices (e.g., vNICs) managed by other Openstack services (e.g., nova).

Starting in the Folsom release, Neutron is a core and supported part of the OpenStack platform (for Essex, we were an "incubated" project, which means use is suggested only for those who really know what they're doing with Neutron). 

Usage notes
===========

For live migration to work, you have to set migration param on bridge and switch nodes.

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

Read more
=========

* https://wiki.openstack.org/wiki/Neutron
* http://docs.openstack.org/havana/install-guide/install/zypper/content/install-neutron.install-plugin.ovs.gre.html
* http://docs.openstack.org/admin-guide-cloud/content//ch_networking.html
* https://github.com/marafa/openstack/blob/master/openstack-outside.sh
* http://techbackground.blogspot.ie/2013/06/metadata-via-quantum-router.html
* http://techbackground.blogspot.ie/2013/06/metadata-via-dhcp-namespace.html
* http://developer.rackspace.com/blog/neutron-networking-l3-agent.html
* http://docs.openstack.org/grizzly/basic-install/apt/content/basic-install_network.html#configure-l3
* ML2 plugin http://openstack.redhat.com/ML2_plugin
* https://github.com/stackforge/fuel-library/tree/master/deployment/puppet/neutron/files
* http://openstack.redhat.com/forum/discussion/972/stable-havana-2013-2-3-update/p1
