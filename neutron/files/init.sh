{%- set networks = pillar.neutron.server.public_networks %}
{%- for network in networks %}
neutron net-create {{ network.name }} --router:external=True --tenant-id admin
{%- for subnet in network.subnets %}
neutron subnet-create --ip_version 4 --tenant-id admin --gateway {{ subnet.gateway }} {{ network.name }} {{ subnet.network }} --allocation-pool start={{ subnet.pool_start }},end={{ subnet.pool_end }} --disable-dhcp --name {{ subnet.name }}
{%- endfor %}
{%- endfor %}