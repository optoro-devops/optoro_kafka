node['optoro_kafka']['log']['devices'].each do |device, params|
  aws_ebs_volume params['mount_path'] do
    description "#{device} on #{node[name]}"
    size params['ebs']['size']
    device params['ebs']['device']
    volume_type params['ebs']['type']
    action [:create, :attach]
    only_if { params['ebs'] && !params['ebs'].keys.empty? }
  end
end
