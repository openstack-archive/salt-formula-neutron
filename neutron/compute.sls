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
{%- endif %}