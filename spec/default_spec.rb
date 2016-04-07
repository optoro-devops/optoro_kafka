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
        it 'includes optoro_kafka::aws when running on EC2' do
          chef_run.node.set['optoro_kafka']['zfs_on_ebs'] = true
          chef_run.node.automatic['ec2'] = true
          chef_run.converge(described_recipe)
          expect(chef_run).to include_recipe('optoro_kafka::aws')
        end
        it 'should delay in restarting kafka' do
          resource = chef_run.execute('untar kafka binary')
          expect(resource).to notify('service[kafka]').to(:restart).delayed
        end
      end
    end
  end
end
