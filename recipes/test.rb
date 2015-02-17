# node.set['fqdn'] = 'test-kafka-001.optoro.com'
<<<<<<< HEAD
node.set['fqdn'] = 'test-kafka-001.optoro.com'
=======
>>>>>>> 9b6f9d5... maybe now?
bash 'set hostname' do
  user 'root'
  code <<-EOH
  echo 127.0.0.1 `hostname` >> /etc/hosts
  EOH
end
