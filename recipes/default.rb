#<
#  Configures and installs kafka.  We use the exhibitor api to get a list of zookeepers.
#
# TODO: support more than one cluster in a chef environment
#>
begin
  node.normal['kafka']['zookeepers'] = [
    zk_connect_str(
      discover_zookeepers(
        "http://#{node['optoro']['kafka_cluster']}-#{node['exhibitor']['base_domain']}:#{node['exhibitor']['cli']['port']}"
      )
    )
  ]
  rescue ExhibitorError
    Chef::Log.warn 'Could not find zookeepers via exhibitor, failing to localhost'
    node.default['kafka']['zookeepers'] = ['localhost:2181']
end

node.default['kafka']['server.properties']['broker.id'] = node['fqdn'].scan(/\d+/).first.to_i

include_recipe 'apt'
include_recipe 'exhibitor'
include_recipe 'cerner_kafka'
include_recipe 'cerner_kafka::offset_monitor'

# override the default action of 'stop' for the untar'ing
# if kafka is not already installed chef errors out.  Delaying instead.
begin
  r = resources(:execute => 'untar kafka binary')
  r.name 'kafka'
  r.notifies :restart, 'service[kafka]', :delayed
  rescue Chef::Exceptions::ResourceNotFound
    Chef::Log.warn 'could not find service to override!'
end
