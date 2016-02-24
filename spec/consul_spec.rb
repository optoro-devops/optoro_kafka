require 'spec_helper'
describe 'optoro_kafka::consul' do
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
      end
    end
  end
end
