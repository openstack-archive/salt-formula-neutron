{% from "neutron/map.jinja" import network with context %}
{%- if network.enabled %}

net.ipv4.ip_forward:
  sysctl.present:
    - value: 1

net.ipv4.conf.default.rp_filter:
  sysctl.present:
    - value: 0

neutron_network_packages:
  pkg.installed:
  - names: {{ network.pkgs }}

{%- if grains.oscodename == 'precise' %}

neutron_network_precise_packages:
  pkg.installed:
  - names: {{ network.precise_pkgs }}

{%- endif %}

{%- if not pillar.neutron.server is defined %}

/etc/neutron/neutron.conf:
  file.managed:
  - source: salt://neutron/files/{{ network.version }}/neutron-network.conf
  - template: jinja
  - require:
    - pkg: neutron_network_packages

/etc/neutron/plugins/ml2/ml2_conf.ini:
  file.managed:
  - source: salt://neutron/files/{{ network.version }}/ml2_conf.ini.{{ grains.os_family }}
  - template: jinja
  - require:
    - pkg: neutron_network_packages

/etc/neutron/plugin.ini:
  file.symlink:
    - target: /etc/neutron/plugins/ml2/ml2_conf.ini
    - require:
      - file: /etc/neutron/plugins/ml2/ml2_conf.ini

{%- endif %}

{% if network.tunnel_type != 'flat' %}

/etc/neutron/plugins/openvswitch:
  file.directory:
  - mode: 755
  - makedirs: true
  - user: neutron
  - group: neutron

/etc/neutron/plugins/openvswitch/ovs_neutron_plugin.ini:
  file.managed:
  - source: salt://neutron/files/{{ network.version }}/ovs_neutron_plugin.ini.{{ grains.os_family }}
  - template: jinja
  - require:
    - pkg: neutron_network_packages
    - file: /etc/neutron/plugins/openvswitch

/etc/neutron/l3_agent.ini:
  file.managed:
  - source: salt://neutron/files/{{ network.version }}/l3_agent.ini.{{ grains.os_family }}
  - template: jinja
  - require:
    - pkg: neutron_network_packages
{% endif %}

/etc/neutron/dhcp_agent.ini:
  file.managed:
  - source: salt://neutron/files/{{ network.version }}/dhcp_agent.ini.{{ grains.os_family }}
  - template: jinja
  - require:
    - pkg: neutron_network_packages

/etc/neutron/metadata_agent.ini:
  file.managed:
  - source: salt://neutron/files/{{ network.version }}/metadata_agent.ini.{{ grains.os_family }}
  - template: jinja
  - require:
    - pkg: neutron_network_packages

/etc/neutron/dnsmasq-neutron.conf:
  file.managed:
  - source: salt://neutron/files/{{ network.version }}/dnsmasq-neutron.conf
  - template: jinja
  - require:
    - pkg: neutron_network_packages

{% if pillar.pacemaker is defined %}
{% if grains.os_family == "RedHat" %}
{% for service in network.services %}

clear_service_{{ service }}:
  cmd.run:
  - name: mv /etc/init.d/{{ service }} /etc/init.d/{{ service }}-dontrun
  - unless: test -e /etc/init.d/{{service }}-dontrun
  - require:
    - pkg: neutron_network_packages


{% endfor %}
{% endif %}
{% else %}

neutron_network_services:
  service.running:
  - names: {{ network.services }}
  - enable: true
  - watch:
    - file: /etc/neutron/neutron.conf
    - file: /etc/neutron/l3_agent.ini
    - file: /etc/neutron/dhcp_agent.ini
    - file: /etc/neutron/metadata_agent.ini
    - file: /etc/neutron/plugins/openvswitch/ovs_neutron_plugin.ini

{% endif %}

{# vondrt4: This is likely obsolete since Icehouse
{% if network.migration %}

fuel_packages:
  pkg.installed:
  - sources: 
    - fuel-utils: salt://neutron/files/fuel-utils_20131119-01.dev13.g4b0ab3a_all
    - python-paramiko: salt://neutron/files/python-paramiko_1.12.0-ubuntu_all.deb
  - require:
    - pkg: python-ecdsa


python-ecdsa:
  pkg.installed:
  - name: python-ecdsa

/usr/bin/q-agent-cleanup.py:
  file.managed:
  - source: salt://neutron/files/q-agent-cleanup.py
  - template: jinja
  - mode: 755
  - user: root
  - group: root
  - require:
    - pkg: neutron_network_packages

{%- if pillar.linux is defined %}

/root/.ssh/id_rsa_neutron:
  file.managed:
  - source: salt://neutron/files/id_rsa
  - contents_pillar: private_keys:neutron:key
  - user: root
  - group: root
  - mode: 600

/root/.ssh/id_rsa_neutron.pub:
  file.managed:
  - source: salt://neutron/files/id_rsa.pub
  - contents_pillar: public_keys:neutron:key
  - user: root
  - group: root
  - mode: 600

neutron_root_auth_key:
  ssh_auth.present:
  - user: root
  - names:
    - {{ salt['pillar.get']('public_keys:neutron:key') }}

{%- else %}

/root/.ssh/id_rsa_neutron:
  file.managed:
  - source: salt://neutron/files/id_rsa
  - template: jinja
  - user: root
  - group: root
  - mode: 600

/root/.ssh/id_rsa_neutron.pub:
  file.managed:
  - source: salt://neutron/files/id_rsa.pub
  - template: jinja
  - user: root
  - group: root
  - mode: 600

neutron_root_auth_key:
  ssh_auth.present:
  - user: root
  - names:
    {%- for public_key in pillar.public_keys.users %}
    {%- if public_key.name == 'neutron' %}
    - {{ public_key.key }}
    {%- endif %}
    {%- endfor %}

{%- endif %}

{% endif %}

#}

gro_disabled:
  cmd.run:
  - name: "ethtool -K eth0 gro off; ethtool -K eth1 gro off; echo 'ethtool -K eth0 gro off; ethtool -K eth1 gro off' >> /etc/rc.local"
  - unless: "cat /etc/rc.local | grep gro"

{%- endif %}