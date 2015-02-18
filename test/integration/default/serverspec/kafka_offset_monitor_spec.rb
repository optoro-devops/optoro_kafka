# coding: UTF-8

require 'spec_helper'

describe service('kafka-offset-monitor') do
  it { should be_running }
end

# Kafka Offset Monitor API
describe port(8080) do
  it { should be_listening }
end

describe 'kafka offset monitor' do

  Dir['/opt/kafka-offset-monitor/**/*'].each do |filePath|
    describe file(filePath) do
      it { should be_owned_by 'kafka' }
      it { should be_grouped_into 'kafka' }
    end
  end

  it 'should be able to connect to offset monitor and get home page' do
    expect(command("wget http://localhost:8080 2>&1 | grep response").stdout).to include('200 OK')
  end

  it 'should be able to get monitoring details page for a topic' do
    # Generate a random topic
    topic_name = 'testNewTopic_' + rand(100_000).to_s

    expect(command("/opt/kafka/bin/kafka-topics.sh --create --topic #{topic_name} --partitions 1 --replication-factor 1 --zookeeper localhost:2181 2> /dev/null").stdout).to include('Created topic')
    sleep 1

    expect(command("wget http://localhost:8080/#/topicdetail/#{topic_name} 2>&1 | grep response").stdout).to include('200 OK')
  end

  it 'should be able to get monitoring details page for a consumer group' do
    # Generate a random topic and group
    topic_name = 'testNewTopic_' + rand(100_000).to_s
    group_name = 'testNewGroup_' + rand(100_000).to_s

    expect(command("/opt/kafka/bin/kafka-topics.sh --create --topic #{topic_name} --partitions 1 --replication-factor 1 --zookeeper localhost:2181 2> /dev/null").stdout).to include('Created topic')

    expect(command("/opt/kafka/bin/kafka-console-consumer.sh --zookeeper localhost:2181 --group #{group_name} --whitelist #{topic_name} --consumer-timeout-ms 500 2>&1").stdout).to include('Consumed 0 messages')

    expect(command("wget http://localhost:8080/#/group/#{group_name} 2>&1 | grep response").stdout).to include('200 OK')
  end

end
