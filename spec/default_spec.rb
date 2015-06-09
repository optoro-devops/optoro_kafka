require 'spec_helper'
describe 'optoro_kafka::default' do
  Resources::PLATFORMS.each do |platform, value|
    value['versions'].each do |version|
      context "On #{platform} #{version}" do
        include_context 'optoro_kafka'
        let(:chef_run) do
          ChefSpec::SoloRunner.new(platform: platform, version: version, log_level: :error) do |node|
            node.set['lsb']['codename'] = value['codename']
            node.set['optoro']['kafka_cluster'] = 'logstash-metrics'
          end.converge(described_recipe)
        end
        it 'includes optoro_zfs and aws when zfs_on_ebs is true' do
          chef_run.node.set['optoro_kafka']['log']['devices'] = nil
          chef_run.node.set['optoro_kafka']['zfs_on_ebs'] = true
          chef_run.converge(described_recipe)
          expect(chef_run).to include_recipe('optoro_zfs')
          expect(chef_run).to include_recipe('optoro_kafka::zfs_on_ebs')
        end
        it 'includes aws' do
          expect(chef_run).to include_recipe('aws')
        end
        it 'includes apt' do
          expect(chef_run).to include_recipe('apt')
        end
        it 'includes exhibitor' do
          expect(chef_run).to include_recipe('exhibitor')
        end
        it 'includes cerner_kafka' do
          expect(chef_run).to include_recipe('cerner_kafka')
        end
        it 'includes cerner_kafka::offset_monitor' do
          expect(chef_run).to include_recipe('cerner_kafka::offset_monitor')
        end
        it 'should delay in restarting kafka' do
          resource = chef_run.execute('untar kafka binary')
          expect(resource).to notify('service[kafka]').to(:restart).delayed
        end
        it 'should create 4 directories for mountpoints' do
          expect(chef_run).to create_directory('/kafka/disk1').with(user: 'kafka', group: 'kafka')
          expect(chef_run).to create_directory('/kafka/disk2').with(user: 'kafka', group: 'kafka')
          expect(chef_run).to create_directory('/kafka/disk3').with(user: 'kafka', group: 'kafka')
          expect(chef_run).to create_directory('/kafka/disk4').with(user: 'kafka', group: 'kafka')
        end
        #it 'should create 4 aws_ebs_volumes' do
        #  expect(chef_run).to create_aws_ebs_volume('/kafka/disk1')
        #  expect(chef_run).to create_aws_ebs_volume('/kafka/disk2')
        #  expect(chef_run).to create_aws_ebs_volume('/kafka/disk3')
        #  expect(chef_run).to create_aws_ebs_volume('/kafka/disk4')
        #end
      end
    end
  end
end
