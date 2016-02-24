require 'spec_helper'

describe 'Consul Service' do
  describe process('consul') do
    it { should be_running }
  end

  describe service('consul') do
    it { should be_enabled }
    it { should be_running }
  end

  describe port(8500) do
    it { should be_listening }
  end

  it 'should be registered' do
    expect(command('curl http://localhost:8500/v1/catalog/service/kafka').stdout)
      .to match(/kafka/)
  end

  it 'should have a passing health check' do
    expect(command('curl http://localhost:8500/v1/health/checks/kafka').stdout)
      .to match(/passing/)
  end
end
