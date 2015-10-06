
include:
{% if pillar.neutron.server is defined %}
- neutron.server
{% endif %}
{% if pillar.neutron.bridge is defined %}
- neutron.bridge
{% endif %}
{% if pillar.neutron.compute is defined %}
- neutron.compute
{% endif %}