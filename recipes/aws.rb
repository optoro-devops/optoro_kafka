include_recipe 'optoro_zfs'
include_recipe 'aws'

node.default['kafka']['server.properties']['log.dirs'] = '/kafka'

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
