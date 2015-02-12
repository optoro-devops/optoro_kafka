# Set some defaults for testing
default['kafka']['brokers'] = [node['fqdn']]
default['kafka']['lib_jars'] = ['http://search.maven.org/remotecontent?filepath=io/dropwizard/metrics/metrics-logback/3.1.0/metrics-logback-3.1.0.jar']
default['kafka']['zookeepers'] = ['localhost:2181']
#default['kafka']['env_vars']['KAFKA_HEAP_OPTS'] = '"-Xmx4G -Xms4G"'
default['kafka']['env_vars']['KAFKA_HEAP_OPTS'] = '"-Xmx1G -Xms1G"'
default['exhibitor']['base_domain'] = 'exhibitor.optoro.io'
