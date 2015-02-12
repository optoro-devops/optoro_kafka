#
# Cookbook Name:: optoro_kafka
# Recipe:: default
#
# Copyright (C) 2014 Zach Dunn
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'apt'
include_recipe 'exhibitor'
include_recipe 'cerner_kafka'
include_recipe 'cerner_kafka::offset_monitor'

# ask the exhibitor in our environment for the zookeepers
# TODO: support more than one cluster in a chef environment
begin
  node.default['kafka']['zookeepers'] = [
    zk_connect_str(
      discover_zookeepers(
        "http://#{node.chef_environment}-#{node.default['exhibitor']['base_domain']}:#{node.default['exhibitor']['cli']['port']}"
      )
    )
  ]
  rescue ExhibitorError
    Chef::Log.warn 'Could not find zookeepers via exhibitor, failing to localhost'
    node.default['kafka']['zookeepers'] = ['localhost:2181']
end

# search for the kafka brokers in this chef environment and create an array
# TODO: Support more than one cluster per chef environment
if Chef::Config[:solo]
  Chef::Log.warn("This recipe uses search. Chef Solo does not support search.")
else
  search(:node, "recipes:optoro_kafka AND chef_environment:#{node.chef_environment}").each do |n|
    node.default['kafka']['brokers'] << "#{n['fqdn']}:#{n['kafka']['server.properties']['port']}"
  end
end

# Dedup our host name out of the array
node.default['kafka']['brokers'] = node['kafka']['brokers'].uniq

# override the default action of 'stop' for the untar'ing
# if kafka is not already installed chef errors out.  Delaying instead.
begin
  r = resources(:execute => 'untar kafka binary')
  r.name 'kafka'
  r.notifies :restart, 'service[kafka]', :delayed
  rescue Chef::Exceptions::ResourceNotFound
    Chef::Log.warn 'could not find service to override!'
end
