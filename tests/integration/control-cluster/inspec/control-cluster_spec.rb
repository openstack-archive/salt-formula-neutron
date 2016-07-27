
neutron = {
  user: 'root',
  group: 'neutron',
}


# TODO, load from control-single
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


# FIXME, there is no opencontrail plugin installed nor configured
# is the metadata dependency missing?
#control 'neutron control cluster' do
  #describe file('/etc/neutron/neutron.conf') do
    #its ('content') {  should match('^core_plugin.*opencontrail.*')}
  #end
  #describe file('/etc/neutron/plugins/opencontrail') do
    #it { should be_directory }
  #end
#end
