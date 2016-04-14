require 'spec_helper'
describe 'optoro_kafka::aws' do
  Resources::PLATFORMS.each do |platform, value|
    value['versions'].each do |version|
      context "On #{platform} #{version}" do
        include_context 'optoro_kafka'
        let(:chef_run) do
          ChefSpec::SoloRunner.new(platform: platform, version: version, log_level: :error) do |node|
            node.set['lsb']['codename'] = value['codename']
            node.set['optoro']['kafka_cluster'] = 'logstash-metrics'
            node.set['optoro_kafka']['log']['devices'] = nil
            node.set['optoro_kafka']['zfs_on_ebs'] = true
            node.automatic['ec2'] = true
          end.converge(described_recipe)
        end
        it 'includes the optoro_zfs cookbook' do
          expect(chef_run).to include_recipe('optoro_zfs')
        end
        it 'includes the aws cookbook' do
          expect(chef_run).to include_recipe('aws')
        end
        it 'should create 4 directories for mountpoints' do
          expect(chef_run).to create_directory('/kafka/disk1')
          expect(chef_run).to create_directory('/kafka/disk2')
          expect(chef_run).to create_directory('/kafka/disk3')
          expect(chef_run).to create_directory('/kafka/disk4')
        end
      end
    end
  end
end
