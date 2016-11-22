{%- from "neutron/map.jinja" import server with context %}
{%- if server.enabled %}

neutron_server_packages:
  pkg.installed:
  - names: {{ server.pkgs }}

{% if server.backend.engine == "openvswitch" %}

/etc/neutron/neutron.conf:
  file.managed:
  - source: salt://neutron/files/{{ server.version }}/neutron-server.conf.{{ grains.os_family }}
  - template: jinja
  - require:
    - pkg: neutron_server_packages

/etc/neutron/plugins/ml2/ml2_conf.ini
  file.managed:
  - source: salt://neutron/files/{{ server.version }}/ml2_conf.ini
  - template: jinja
  - require:
    - pkg: neutron_server_packages

neutron_server_service:
  service.running:
  - names: {{ server.services }}
  - enable: true
  - watch:
    - file: /etc/neutron/neutron.conf
    - file: /etc/neutron/plugins/ml2/ml2_conf.ini

{% if server.backend.engine == "contrail" %}

/etc/neutron/plugins/opencontrail/ContrailPlugin.ini:
  file.managed:
  - source: salt://neutron/files/{{ server.version }}/ContrailPlugin.ini
  - template: jinja
  - require:
    - pkg: neutron_server_packages
    - pkg: neutron_contrail_package

contrail_plugin_link:
  cmd.run:
  - names:
    - ln -s /etc/neutron/plugins/opencontrail/ContrailPlugin.ini /etc/neutron/plugin.ini
  - unless: test -e /etc/neutron/plugin.ini
  - require:
    - file: /etc/neutron/plugins/opencontrail/ContrailPlugin.ini

neutron_contrail_package:
  pkg.installed:
  - name: neutron-plugin-contrail

neutron_server_service:
  service.running:
  - name: neutron-server
  - enable: true
  - watch:
    - file: /etc/neutron/neutron.conf

{%- endif %}

/etc/neutron/neutron.conf:
  file.managed:
  - source: salt://neutron/files/{{ server.version }}/neutron-server.conf.{{ grains.os_family }}
  - template: jinja
  - require:
    - pkg: neutron_server_packages

{%- if grains.os_family == "Debian" %}

/etc/default/neutron-server:
  file.managed:
  - source: salt://neutron/files/{{ server.version }}/neutron-server
  - template: jinja
  - require:
    - pkg: neutron_server_packages
{%- if not grains.get('noservices', False) %}
  - watch_in:
    - service: neutron_server_services

{%- endif %}

{%- endif %}

{%- if server.backend.engine == "midonet" %}

/etc/neutron/plugins/midonet/midonet.ini:
  file.managed:
    - source: salt://neutron/files/{{ server.version }}/midonet.ini
    - user: root
    - group: root
    - mode: 644
    - makedirs: true
    - dir_mode: 755
    - template: jinja

neutron_db_manage:
  cmd.run:
  - name: neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/midonet/midonet.ini upgrade head
  - require:
    - file: /etc/neutron/neutron.conf
    - file: /etc/neutron/plugins/midonet/midonet.ini

{%- if server.version == "kilo" %}

midonet_neutron_packages:
  pkg.installed:
  - names:
    - python-neutron-plugin-midonet
    - python-neutron-lbaas

midonet-db-manage:
  cmd.run:
  - name: midonet-db-manage upgrade head

{%- else %}

midonet_neutron_packages:
  pkg.installed:
  - names:
    - python-networking-midonet
    - python-neutron-lbaas
    - python-neutron-fwaas

neutron_db_manage:
  cmd.run:
  - name: neutron-db-manage --subproject networking-midonet upgrade head
  - require:
    - file: /etc/neutron/neutron.conf
    - file: /etc/neutron/plugins/midonet/midonet.ini

{%- endif %}
{%- endif %}

{%- if not grains.get('noservices', False) %}

neutron_server_services:
  service.running:
  - names: {{ server.services }}
  - enable: true
  - watch:
    - file: /etc/neutron/neutron.conf

{%- endif %}

{%- if grains.get('virtual_subtype', None) == "Docker" %}

neutron_entrypoint:
  file.managed:
  - name: /entrypoint.sh
  - template: jinja
  - source: salt://neutron/files/entrypoint.sh
  - mode: 755

{%- endif %}

{%- endif %}
