#<
#  Configures and installs kafka.  We use the exhibitor api to get a list of zookeepers.
#
# TODO: support more than one cluster in a chef environment
#>
include_recipe 'optoro_zfs'
include_recipe 'aws'

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

if node['ec2']
  node['optoro_kafka']['disks'].each do |disk, index|
    aws_ebs_volume "kafka-#{index}" do
      size node['optoro_kafka']['disk_size']
      device disk
      action [:create, :attach]
    end
  end

  # make our disk names compatible with what ubuntu sees.
  # e.g. /dev/sdf will become /dev/xvdf
  virtual_disks = node['optoro_kafka']['disks'].map { |disk| disk.sub('/dev/s', '/dev/xv') }

  zpool 'kafka' do
    disks virtual_disks
    force true
  end

  zfs 'kafka' do
    mountpoint node['kafka']['server.properties']['log.dirs']
    atime 'off'
    compression 'lz4'
  end
end

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
