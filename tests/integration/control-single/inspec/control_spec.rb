
# TODO, enable helper files once resolved - https://github.com/chef/kitchen-inspec/issues/93
#require 'neutron_spec'
#require 'spec_helper'

neutron = {
  user: 'root',
  group: 'neutron',
}

# TODO, pay attention/fix the cfg file ownership
# -rw-r--r--   1 root neutron  1017 Jun 18  2015 api-paste.ini
# -rw-r--r--   1 root neutron   109 Jun 18  2015 fwaas_driver.ini
# -rw-r--r--   1 root neutron  3109 Jun 18  2015 l3_agent.ini
# -rw-r--r--   1 root root     1400 Jun 18  2015 lbaas_agent.ini
# -rw-r--r--   1 root neutron 17867 Mar  9 18:42 neutron.conf
# drwxr-xr-x   3 root neutron  4096 Jul  8 06:37 plugins/
# -rw-r--r--   1 root neutron  5858 Jun 18  2015 policy.json
# -rw-r--r--   1 root root     1216 Jun 18  2015 rootwrap.conf
# drwxr-xr-x   2 root root     4096 Jul  8 06:38 rootwrap.d/
# -rw-r--r--   1 root neutron   526 Jun 18  2015 vpn_agent.ini

# TODO, replace with shared controls
control 'neutron control' do
  describe file('/etc/neutron/neutron.conf') do
    it { should exist }
    it { should be_owned_by neutron[:user] }
    it { should be_grouped_into neutron[:group] }
  end

  describe file('/var/log/neutron') do
    it { should be_directory }
  end

  describe file('/var/lib/neutron') do
    it { should be_directory }
  end
end

control 'neutron control single' do
  describe file('/etc/neutron/neutron.conf') do
    its ('content') {  should match('^core_plugin.*ml2.*')}
  end
  describe file('/etc/neutron/plugins/ml2') do
    it { should be_directory }
  end
end

