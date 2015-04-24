#<
# Test recipe.  Helps set some defualts so we can run our tests.
#>

node.set['fqdn'] = 'test-kafka-001.optoro.com'
bash 'set hostname' do
  user 'root'
  code <<-EOH
  echo 127.0.0.1 `hostname` >> /etc/hosts
  EOH
end

cookbook_file 'offsetmonitor-consumer-test.properties' do
  path '/tmp/offsetmonitor-consumer-test.properties'
end
