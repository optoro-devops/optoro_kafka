# Set some defaults for testing
default['kafka']['brokers'] = [node['fqdn']]
default['kafka']['lib_jars'] = ['http://search.maven.org/remotecontent?filepath=io/dropwizard/metrics/metrics-logback/3.1.0/metrics-logback-3.1.0.jar',
                                'https://repo1.maven.org/maven2/org/slf4j/slf4j-nop/1.7.7/slf4j-nop-1.7.7.jar',
                                'https://repo1.maven.org/maven2/org/slf4j/slf4j-api/1.7.7/slf4j-api-1.7.7.jar']
default['kafka']['zookeepers'] = ['localhost:2181']
default['kafka']['env_vars']['KAFKA_HEAP_OPTS'] = '"-Xmx1G -Xms1G"'
default['exhibitor']['base_domain'] = 'exhibitor.optoro.io'

override['kafka']['server.properties']['log.dirs'] = '/kafka'
default['kafka']['scala_version'] = '2.10'
default['kafka']['version'] = '0.8.2.1'
default['optoro_kafka']['disks'] = ['/dev/sdf']
default['optoro_kafka']['disk_size'] = 1024
