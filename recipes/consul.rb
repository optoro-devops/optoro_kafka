include_recipe 'optoro_consul::client'

optoro_consul_service 'kafka' do
  port 6667
  params node['optoro_consul']['service']
end
