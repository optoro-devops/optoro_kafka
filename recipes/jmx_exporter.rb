include_recipe 'optoro_consul::client'

package 'jmx_prometheus_httpserver' do
  action :upgrade
end

cookbook_file '/etc/jmx_exporter/jmx_exporter.yaml' do
  source 'jmx_exporter.yaml'
  owner 'root'
  group 'root'
  mode '0644'
end

cookbook_file '/etc/init/jmx_exporter.conf' do
  source 'jmx_exporter.init'
  owner 'root'
  group 'root'
  mode '0755'
end

service 'jmx_exporter' do
  action [:enable, :start]
end

consul_definition 'kafka-metrics' do
  type 'service'
  parameters(
    port: 9200,
    tags: [node['fqdn'], 'kafka'],
    enableTagOverride: false,
    check: {
      interval: '10s',
      timeout: '5s',
      http: 'http://localhost:9200/metrics'
    }
  )
  notifies :reload, 'consul_service[consul]', :delayed
end
