{%- from "neutron/map.jinja" import server with context -%}
#!/bin/bash -e

cat /srv/salt/pillar/neutron-server.sls | envsubst > /tmp/neutron-server.sls
mv /tmp/neutron-server.sls /srv/salt/pillar/neutron-server.sls

salt-call --local --retcode-passthrough state.highstate

{% for service in server.services %}
service {{ service }} stop || true
{% endfor %}

if [ "$1" == "server" ]; then
    echo "starting neutron-server"
    su neutron --shell=/bin/sh -c '/usr/bin/neutron-server --config-file=/etc/neutron/neutron.conf --config-file=/etc/neutron/plugins/opencontrail/ContrailPlugin.ini'
elif [ "$1" == "lbaas-agent" ]; then
    echo "starting neutron-lbaas-agent"
    su neutron --shell=/bin/sh -c '/usr/bin/neutron-lbaas-agent --config-file=/etc/neutron/neutron.conf'
else
    echo "No parameter submitted, don't know what to start" 1>&2
fi

{#-
vim: syntax=jinja
-#}