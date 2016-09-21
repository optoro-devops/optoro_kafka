#<
#  Configures and installs kafka.  We use the exhibitor api to get a list of zookeepers.
#
# TODO: support more than one cluster in a chef environment
#>

# Get a list of Zookeepers back from exhibitor
begin
  exhibitor_endpoint = "http://#{node['optoro']['kafka_cluster']}-#{node['exhibitor']['base_domain']}:#{node['exhibitor']['cli']['port']}"
  node.normal['kafka']['zookeepers'] = [
    zk_connect_str(discover_zookeepers(exhibitor_endpoint))
  ]
rescue ExhibitorError
  Chef::Log.warn 'Could not find zookeepers via exhibitor, failing to localhost'
  node.default['kafka']['zookeepers'] = ['localhost:2181']
end

node.default['kafka']['server.properties']['broker.id'] = node['fqdn'].scan(/\d+/).first.to_i

group node['kafka']['group'] do
  action :create
end

user node['kafka']['user'] do
  comment 'Kafka user'
  uid node['kafka']['uid'] if node['kafka']['uid']
  gid node['kafka']['group']
  shell '/bin/bash'
  home "/home/#{node['kafka']['user']}"
  supports :manage_home => true
end

include_recipe 'optoro_kafka::aws' if node['ec2']

include_recipe 'ulimit'

user_ulimit 'kafka' do
  filehandle_limit '65535'
end

include_recipe 'apt'
include_recipe 'exhibitor'
include_recipe 'cerner_kafka'
include_recipe 'cerner_kafka::offset_monitor'
include_recipe 'optoro_kafka::jmx_exporter'

# override the default action of 'stop' for the untar'ing
# if kafka is not already installed chef errors out.  Delaying instead.
begin
  r = resources(:execute => 'untar kafka binary')
  r.name 'kafka'
  r.notifies :restart, 'service[kafka]', :delayed
rescue Chef::Exceptions::ResourceNotFound
  Chef::Log.warn 'could not find service to override!'
end

file '/opt/kafka/libs/kafka-graphite-1.0.0.jar' do
  action :delete
end
