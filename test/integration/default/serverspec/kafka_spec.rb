# coding: UTF-8

require 'spec_helper'

describe user('kafka') do
  it { should exist }
  it { should belong_to_group 'kafka' }
end

describe service('kafka') do
  it { should be_running }
end

# Kafka Broker API
describe port(6667) do
  it { should be_listening }
end

# Kafka JMX Exporter
describe port(9200) do
  it { should be_listening }
end

describe service('jmx_exporter') do
  it { should be_running }
end

# Kafka Broker JMX
describe port(9999) do
  it { should be_listening }
end

describe file('/opt/kafka/libs/metrics-logback-3.1.0.jar') do
  it { should be_file }
  it { should be_owned_by 'kafka' }
  it { should be_grouped_into 'kafka' }
end

describe file('/opt/kafka/libs/metrics-core-2.2.0.jar') do
  it { should be_file }
  it { should be_owned_by 'kafka' }
  it { should be_grouped_into 'kafka' }
end

describe file('/opt/kafka/libs/metrics-graphite-2.2.0.jar') do
  it { should be_file }
  it { should be_owned_by 'kafka' }
  it { should be_grouped_into 'kafka' }
end

describe file('/opt/kafka/libs/kafka-graphite-1.0.4.jar') do
  it { should be_file }
  it { should be_owned_by 'kafka' }
  it { should be_grouped_into 'kafka' }
end

describe file('/opt/kafka/config/server.properties') do
  it { should be_file }
  it { should be_owned_by 'kafka' }
  it { should be_grouped_into 'kafka' }
end

describe file('/opt/kafka/config/log4j.properties') do
  it { should be_file }
  it { should be_owned_by 'kafka' }
  it { should be_grouped_into 'kafka' }
end

describe file('/etc/kafka') do
  it { should be_directory }
  it { should be_linked_to '/opt/kafka/config' }
end

describe file('/etc/kafka') do
  it { should be_directory }
  it { should be_linked_to '/opt/kafka/config' }
end

describe 'kafka broker' do
  Dir['/opt/kafka/**/*'].each do |file_path|
    describe file(file_path) do
      it { should be_owned_by 'kafka' }
      it { should be_grouped_into 'kafka' }
    end
  end

  it 'should export all environment variables' do
    # For some reason having su run echo itself does not pickup the environment variables but it works if run in another shell script
    # This is ok since this is how we start Kafka (via scripts)
    File.open('/tmp/env_jmx.sh', 'w') { |file| file.write('echo "$JMX_PORT"') }

    # Make the scripts executable
    Kernel.system 'chmod 755 /tmp/env_jmx.sh'

    output = `su -l kafka -c "/tmp/env_jmx.sh 2> /dev/null"`
    expect(output).to include('9999')
  end

  it 'should be able to create a topic' do
    # Pick a random topic so if we re-run the tests on the same VM it won't fail with 'topic already created'
    topic_name = 'testNewTopic_' + rand(100_000).to_s

    create_output = `/opt/kafka/bin/kafka-topics.sh --create --topic #{topic_name} --partitions 1 --replication-factor 1 --zookeeper localhost:2181 2> /dev/null`
    expect(create_output).to include('Created topic')

    list_output = `/opt/kafka/bin/kafka-topics.sh --list --zookeeper localhost:2181 2> /dev/null`
    expect(list_output).to include(topic_name)
  end

  it 'should be able to read/write from a topic' do
    topic = 'superTopic_' + rand(100_000).to_s
    message = 'super secret message'

    # Ensure the topic is created before having the consumer listen for it
    Kernel.system "/opt/kafka/bin/kafka-topics.sh --create --topic #{topic} --partitions 1 --replication-factor 1 --zookeeper localhost:2181 2> /dev/null"

    # The consumer command allows a user to 'listen' for messages on the topic and write them to STDOUT as they come in
    # In this case we are re-directing STDOUT to a file so we can read later
    # We also run this as a background process so we can also start the producer
    Kernel.system "/opt/kafka/bin/kafka-console-consumer.sh --zookeeper localhost:2181 --whitelist #{topic} >> /tmp/consumer.out 2>&1 &"

    # Delay producing of messages so the consumer has time to start up
    sleep(60)

    # The producer is a command that allows a user to write input to the console as 'messages' to the topic, separated by new line characters
    # In this case we run the command and write the same message several times over 5s in an attempt to ensure the consumer saw the message
    # rubocop:disable UselessAssignment
    IO.popen("/opt/kafka/bin/kafka-console-producer.sh --topic #{topic} --broker-list localhost:6667 2> /dev/null", mode = 'r+') do |io|
      writes = 5
      while writes > 0
        io.write message + '\n'
        writes -= 1
        sleep 1
      end
      io.close_write
    end
    # rubocop:enable UselessAssignment

    # Ensure consumer processes are stopped
    consumer_pids = `ps -ef | grep kafka.consumer.ConsoleConsumer | grep -v grep | awk '{print $2}'`
    consumer_pids.split('\n').each do |pid|
      Process.kill 9, pid.to_i
    end

    # Read the consumer's STDOUT file
    consumer_output = IO.read('/tmp/consumer.out')

    # Verify the consumer saw at least 1 message
    expect(consumer_output).to include(message)
  end
end
