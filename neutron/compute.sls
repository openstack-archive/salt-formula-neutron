{% from "neutron/map.jinja" import compute with context %}
{%- if compute.enabled %}

net.ipv4.ip_forward:
  sysctl.present:
    - value: 1

neutron_compute_packages:
  pkg.installed:
  - names: {{ compute.pkgs }}

{%- if compute.distributed %}

neutron_compute_packages_dvr:
  pkg.installed:
  - names: {{ compute.pkgs_dvr }}

{%- endif %}

/etc/neutron/neutron.conf:
  file.managed:
  - source: salt://neutron/files/{{ compute.version }}/neutron-compute.conf.{{ grains.os_family }}
  - template: jinja
  - require:
    - pkg: neutron_compute_packages

{% if grains.os_family == 'Debian' %}
/etc/neutron/api-paste.ini:
  file.managed:
  - source: salt://neutron/files/{{ compute.version }}/api-paste.ini.{{ grains.os_family }}
  - template: jinja
  - require:
    - pkg: neutron_compute_packages
{% endif %}

/etc/neutron/plugins/openvswitch:
  file.directory:
  - mode: 755
  - makedirs: true
  - user: neutron
  - group: neutron

/etc/neutron/plugins/openvswitch/ovs_neutron_plugin.ini:
  file.managed:
  - source: salt://neutron/files/{{ compute.version }}/ovs_neutron_plugin-compute.ini.{{ grains.os_family }}
  - template: jinja
  - require:
    - pkg: neutron_compute_packages
    - file: /etc/neutron/plugins/openvswitch

/etc/neutron/plugins/ml2/ml2_conf.ini:
  file.managed:
  - source: salt://neutron/files/{{ compute.version }}/ml2_conf-compute.ini.{{ grains.os_family }}
  - template: jinja
  - require:
    - pkg: neutron_compute_packages

neutron_compute_services:
  service.running:
  - names: {{ compute.services }}
  - enable: true
  - watch:
    - file: /etc/neutron/neutron.conf
    - file: /etc/neutron/plugins/ml2/ml2_conf.ini
    #- file: /etc/neutron/plugins/openvswitch/ovs_neutron_plugin.ini

{%- if compute.distributed %}

/etc/neutron/l3_agent.ini:
  file.managed:
  - source: salt://neutron/files/{{ compute.version }}/l3_agent.ini.{{ grains.os_family }}
  - template: jinja
  - require:
    - pkg: neutron_compute_packages_dvr

/etc/neutron/metadata_agent.ini:
  file.managed:
  - source: salt://neutron/files/{{ compute.version }}/metadata_agent.ini.{{ grains.os_family }}
  - template: jinja
  - require:
    - pkg: neutron_compute_packages_dvr

neutron_compute_services_dvr:
  service.running:
  - names: {{ compute.services_dvr }}
  - enable: true
  - watch:
    - file: /etc/neutron/neutron.conf
    - file: /etc/neutron/plugins/ml2/ml2_conf.ini
    - file: /etc/neutron/l3_agent.ini
    - file: /etc/neutron/metadata_agent.ini

{%- endif %}

{# vondrt4: This is likely obsolete since Icehouse
{% if compute.get('migration', False) %}

/usr/bin/q-agent-cleanup.py:
  file.managed:
  - source: salt://neutron/files/q-agent-cleanup.py
  - template: jinja
  - mode: 755
  - user: root
  - group: root
  - require:
    - pkg: neutron_compute_packages

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

# vondrt4: This should not be necessary. l3-agent needed for DVR!
neutron_compute_absent_services:
  file.absent:
  - names:
    - /etc/init.d/neutron-dhcp-agent
    - /etc/init.d/neutron-l3-agent
    - /etc/init.d/neutron-metadata-agent
    - /etc/init.d/neutron-server
    - /etc/init.d/neutron-lbaas-agent
  - require:
    - pkg: neutron_compute_packages

{% endif %}
#}

{%- endif %}