# Set some defaults for testing

#Kafka defaults
default['kafka']['brokers'] = [node['fqdn']]
default['kafka']['lib_jars'] = ['http://search.maven.org/remotecontent?filepath=io/dropwizard/metrics/metrics-logback/3.1.0/metrics-logback-3.1.0.jar',
                                'https://repo1.maven.org/maven2/org/slf4j/slf4j-nop/1.7.7/slf4j-nop-1.7.7.jar',
                                'https://repo1.maven.org/maven2/org/slf4j/slf4j-api/1.7.7/slf4j-api-1.7.7.jar',
                                'https://s3.amazonaws.com/optoro-packages/kafka-graphite-1.0.0.jar',
                                'https://s3.amazonaws.com/optoro-packages/metrics-core-2.2.0.jar',
                                'https://s3.amazonaws.com/optoro-packages/metrics-graphite-2.2.0.jar']
default['kafka']['zookeepers'] = ['localhost:2181']
default['kafka']['env_vars']['KAFKA_HEAP_OPTS'] = '"-Xmx1G -Xms1G"'
default['kafka']['scala_version'] = '2.10'
default['kafka']['version'] = '0.8.2.1'
default['kafka']['server.properties']['kafka.metrics.reporters'] = 'com.criteo.kafka.KafkaGraphiteMetricsReporter'
default['kafka']['server.properties']['kafka.graphite.metrics.host'] = 'localhost'
default['kafka']['server.properties']['kafka.graphite.metrics.port'] = '6008'
default['kafka']['server.properties']['kafka.graphite.metrics.group'] = "#{node['fqdn']}.kafka"
default['kafka']['server.properties']['kafka.graphite.metrics.reporter.enabled'] = 'true'
default['kafka']['server.properties']['advertised.host.name'] = node['fqdn']
default['kafka']['offset_monitor']['refresh'] = '1.minutes'

# Exhibitor domain
default['exhibitor']['base_domain'] = 'exhibitor.optoro.io'

# If in EC2, we will mount a ZFS file system as a RAID0
default['optoro_kafka']['zfs_on_ebs'] = false
default['optoro_kafka']['disks'] = ['/dev/sdf']
default['optoro_kafka']['disk_size'] = 1024
default['optoro_kafka']['skip_restart'] = false

# Optoro_ZFS defaults, only used if we set "default['optoro_kafka']['zfs_on_ebs'] = true"
default['optoro_zfs']['zfs_arc_max'] = (node['memory']['total'].to_i * 0.05 * 1024).round(0).to_s
