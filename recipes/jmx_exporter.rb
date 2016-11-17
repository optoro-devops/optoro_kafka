include_recipe 'optoro_consul::client'

directory '/etc/jmx_exporter' do
  owner 'root'
  group 'root'
  mode '0755'
end

cookbook_file '/etc/jmx_exporter/jmx_exporter.yaml' do
  source 'jmx_exporter.yaml'
  owner 'root'
  group 'root'
  mode '0644'
end

service 'jmx_exporter' do
  action [:disable, :stop]
end

cookbook_file '/etc/init/jmx_exporter.conf' do
  action :delete
  source 'jmx_exporter.init'
  owner 'root'
  group 'root'
  mode '0755'
end

consul_definition 'kafka-metrics' do
  type 'service'
  parameters(
    port: 7071,
    tags: [node['fqdn'], 'kafka'],
    enableTagOverride: false,
    check: {
      interval: '10s',
      timeout: '5s',
      http: 'http://localhost:7071/metrics'
    }
  )
  notifies :reload, 'consul_service[consul]', :delayed
end
