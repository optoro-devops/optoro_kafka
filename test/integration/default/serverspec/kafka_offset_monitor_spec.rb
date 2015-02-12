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

  it 'should own all files' do
    # Ensure we reload ruby's usernames/groups
    Etc.endgrent
    Etc.endpwent
    Dir['/opt/kafka-offset-monitor/**/*'].each do |filePath|
      expect(Etc.getpwuid(File.stat(filePath).uid).name).to eq('kafka')
      expect(Etc.getgrgid(File.stat(filePath).gid).name).to eq('kafka')
    end
  end

  it 'should be able to connect to offset monitor and get home page' do
    wget_output = `wget http://localhost:8080 2>&1 | grep response`
    expect(wget_output).to include('200 OK')
  end

  it 'should be able to get monitoring details page for a topic' do
    # Generate a random topic
    topic_name = 'testNewTopic_' + rand(100_000).to_s

    create_output = `/opt/kafka/bin/kafka-topics.sh --create --topic #{topic_name} --partitions 1 --replication-factor 1 --zookeeper localhost:2181 2> /dev/null`
    expect(create_output).to include('Created topic')
    sleep 1

    wget_output = `wget http://localhost:8080/#/topicdetail/#{topic_name} 2>&1 | grep response`
    expect(wget_output).to include('200 OK')
  end

  it 'should be able to get monitoring details page for a consumer group' do
    # Generate a random topic and group
    topic_name = 'testNewTopic_' + rand(100_000).to_s
    group_name = 'testNewGroup_' + rand(100_000).to_s

    create_output = `/opt/kafka/bin/kafka-topics.sh --create --topic #{topic_name} --partitions 1 --replication-factor 1 --zookeeper localhost:2181 2> /dev/null`
    expect(create_output).to include('Created topic')

    consumer_output = `/opt/kafka/bin/kafka-console-consumer.sh --zookeeper localhost:2181 --group #{group_name} --whitelist #{topic_name} --consumer-timeout-ms 500 2>&1`
    expect(consumer_output).to include('Consumed 0 messages')

    wget_output = `wget http://localhost:8080/#/group/#{group_name} 2>&1 | grep response`
    expect(wget_output).to include('200 OK')
  end

end
