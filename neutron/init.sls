
include:
{% if pillar.neutron.server is defined %}
- neutron.server
{% endif %}
{% if pillar.neutron.gateway is defined %}
- neutron.gateway
{% endif %}
{% if pillar.neutron.compute is defined %}
- neutron.compute
{% endif %}