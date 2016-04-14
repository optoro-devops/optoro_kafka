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
            node.automatic['ec2'] = true
          end.converge(described_recipe)
        end

        it 'includes the optoro_zfs cookbook' do
          expect(chef_run).to include_recipe('optoro_zfs')
        end

        it 'includes the aws cookbook' do
          expect(chef_run).to include_recipe('aws')
        end
      end
    end
  end
end
