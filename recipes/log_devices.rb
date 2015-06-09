#<
# build and attach log dirs
# adapted from: https://github.com/elastic/cookbook-elasticsearch/blob/master/recipes/data.rb
# and https://github.com/elastic/cookbook-elasticsearch/blob/master/libraries/create_ebs.rb
#>

include_recipe 'optoro_kafka::create_ebs'

node['optoro_kafka']['log']['devices'].each do |device, params|

  # Format volume if format command is provided and volume is unformatted
  bash "Format device: #{device}" do
    command  = "#{params[:format_command]} #{device}"
    fs_check = params[:fs_check_command] || 'dumpe2fs'

    code command

    only_if { params[:format_command] }
    not_if "#{fs_check} #{device}"
  end

  # Create directory with proper permissions
  directory params[:mount_path] do
    owner node['kafka']['user']
    group node['kafka']['group']
    mode 0755
    recursive true
  end

  # Mount device to Kafka data path
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
