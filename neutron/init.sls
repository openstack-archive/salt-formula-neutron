
include:
{% if pillar.neutron.server is defined %}
- neutron.server
{% endif %}
{% if pillar.neutron.network is defined %}
- neutron.network
{% endif %}
{% if pillar.neutron.compute is defined %}
- neutron.compute
{% endif %}