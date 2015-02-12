describe 'optoro_kafka::default' do
  Resources::PLATFORMS.each do |platform, value|
    value['versions'].each do |version|
      context "On #{platform} #{version}" do
        include_context 'optoro_kafka'

        let(:chef_run) do
          ChefSpec::SoloRunner.new(platform: platform, version: version, log_level: :error) do |node|
            env = Chef::Environment.new
            env.name 'test-kitchen'
            allow(node).to receive(:chef_environment).and_return(env.name)
            allow(Chef::Environment).to receive(:load).and_return(env)
            node.set['lsb']['codename'] = value['codename']
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
        it 'should delay in restarting kafka' do
          resource = chef_run.execute('untar kafka binary')
          expect(resource).to notify('service[kafka]').to(:restart).delayed
        end
      end
    end
  end
end
