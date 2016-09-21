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
