include_recipe 'optoro_zfs'
include_recipe 'aws'

node['optoro_kafka']['log']['devices'].each do |device, params|
  aws_ebs_volume params['mount_path'] do
    description "#{device} on #{node[name]}"
    size params['ebs']['size']
    device params['ebs']['device']
    volume_type params['ebs']['type']
    action [:create, :attach]
    only_if { params['ebs'] && !params['ebs'].keys.empty? }
  end

  bash "Format device: #{device}" do
    command  = "#{params[:format_command]} #{device}"
    fs_check = params[:fs_check_command] || 'dumpe2fs'

    code command

    only_if { params[:format_command] }
    not_if "#{fs_check} #{device}"
  end

  directory params[:mount_path] do
    mode 0755
    recursive true
  end

  mount params['mount_path'] do
    mount_point params['mount_path']
    device device
    fstype params['file_system']
    options params['mount_options']
    action [:mount, :enable]

    only_if { File.exist?(device) }
    if node['kafka']['server.properties']['log.dirs'].include?(params['mount_path'])
      Chef::Log.debug 'Scheduling Kafka service restart...'
      notifies :restart, 'service[kafka]', :delayed unless node['optoro_kafka']['skip_restart']
    end
  end
end

group node['kafka']['group'] do
  action :create
end

user node['kafka']['user'] do
  comment 'Kafka user'
  uid node['kafka']['uid'] if node['kafka']['uid']
  gid node['kafka']['group']
  shell '/bin/bash'
  home "/home/#{node['kafka']['user']}"
  supports :manage_home => true
end

node['optoro_kafka']['disks'].each_with_index do |disk, index|
  aws_ebs_volume "kafka-#{index}" do
    size node['optoro_kafka']['disk_size']
    device disk
    action [:create, :attach]
  end
end

zpool 'kafka' do
  disks node['optoro_kafka']['disks'].map { |disk| disk.sub('/dev/s', '/dev/xv') }
  force true
end

zfs 'kafka' do
  mountpoint node['kafka']['server.properties']['log.dirs']
  atime 'off'
  compression 'lz4'
end

directory node['kafka']['server.properties']['log.dirs'] do
  owner 'kafka'
  group 'kafka'
end
