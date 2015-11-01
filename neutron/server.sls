{%- from "neutron/map.jinja" import server with context %}
{%- if server.enabled %}

neutron_server_packages:
  pkg.installed:
  - names: {{ server.pkgs }}

{% if server.plugin != "contrail" %}

/etc/neutron/neutron.conf:
  file.managed:
  - source: salt://neutron/files/{{ pillar.neutron.server.version }}/neutron-server.conf.{{ grains.os_family }}
  - template: jinja
  - require:
    - pkg: neutron_server_packages
    {%- if server.plugin == "ml2" %}
    - pkg: neutron_server_ml2_package
    {%- endif %}

/etc/neutron/api-paste.ini:
  file.managed:
  - source: salt://neutron/files/{{ pillar.neutron.server.version }}/api-paste.ini.{{ grains.os_family }}
  - template: jinja
  - require:
    - pkg: neutron_server_packages

/etc/neutron/init.sh:
  file.managed:
  - source: salt://neutron/files/init.sh
  - template: jinja
  - mode: 700
  - user: root
  - group: root
  - require:
    - pkg: neutron_server_packages

neutron_syncdb:
  cmd.run:
  - name: neutron-db-manage --config-file=/etc/neutron/neutron.conf upgrade head
  - require:
    - file: /etc/neutron/neutron.conf

{%- endif %}

{% if server.plugin == "ml2" %}

neutron_server_ml2_package:
  pkg.installed:
  - names: {{ server.pkgs_ml2 }}

/etc/neutron/plugins/ml2/ml2_conf.ini:
  file.managed:
  - source: salt://neutron/files/{{ pillar.neutron.server.version }}/ml2_conf.ini.{{ grains.os_family }}
  - template: jinja
  - require:
    - pkg: neutron_server_packages

/etc/neutron/plugin.ini:
  file.symlink:
    - target: /etc/neutron/plugins/ml2/ml2_conf.ini
    - require:
      - file: /etc/neutron/plugins/ml2/ml2_conf.ini

{%- endif %}

{% if server.plugin == "contrail" %}

/etc/neutron/neutron.conf:
  file.managed:
  - source: salt://neutron/files/{{ server.version }}/neutron-server.conf.contrail.{{ grains.os_family }}
  - template: jinja
  - require:
    - pkg: neutron_server_packages

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

{%- if grains.os_family == "Debian" %}

/etc/default/neutron-server:
  file.managed:
  - source: salt://neutron/files/{{ server.version }}/neutron-server
  - template: jinja
  - require:
    - pkg: neutron_server_packages
  - watch_in:
    - service: neutron_server_services

{%- endif %}

{%- endif %}

neutron_server_services:
  service.running:
  - names: {{ server.services }}
  - enable: true
  - watch:
    - file: /etc/neutron/neutron.conf

{%- endif %}
