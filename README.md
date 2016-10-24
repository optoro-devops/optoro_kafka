# Description

Installs and configures Kafka

# Requirements

## Platform:

* ubuntu (= 14.04)

## Cookbooks:

* apt
* optoro_zfs
* cerner_kafka (~> 2.3.0)
* exhibitor (~> 0.4.0)
* optoro_zookeeper
* ulimit
* zookeeper
* optoro_consul

# Attributes

* `node['kafka']['brokers']` -  Defaults to `[ ... ]`.
* `node['kafka']['lib_jars']` -  Defaults to `[ ... ]`.
* `node['kafka']['zookeepers']` -  Defaults to `[ ... ]`.
* `node['kafka']['env_vars']['KAFKA_HEAP_OPTS']` -  Defaults to `"-Xmx1G -Xms1G"`.
* `node['kafka']['scala_version']` -  Defaults to `2.10`.
* `node['kafka']['version']` -  Defaults to `0.8.2.1`.
* `node['kafka']['server.properties']['kafka.metrics.reporters']` -  Defaults to `com.criteo.kafka.KafkaGraphiteMetricsReporter`.
* `node['kafka']['server.properties']['kafka.graphite.metrics.host']` -  Defaults to `localhost`.
* `node['kafka']['server.properties']['kafka.graphite.metrics.port']` -  Defaults to `6008`.
* `node['kafka']['server.properties']['kafka.graphite.metrics.group']` -  Defaults to `#{node['fqdn']}.kafka`.
* `node['kafka']['server.properties']['kafka.graphite.metrics.reporter.enabled']` -  Defaults to `true`.
* `node['kafka']['server.properties']['advertised.host.name']` -  Defaults to `node['fqdn']`.
* `node['kafka']['server.properties']['port']` -  Defaults to `6667`.
* `node['kafka']['offset_monitor']['refresh']` -  Defaults to `1.minutes`.
* `node['exhibitor']['base_domain']` -  Defaults to `exhibitor.optoro.io`.
* `node['optoro_kafka']['disks']` -  Defaults to `[ ... ]`.
* `node['optoro_kafka']['disk_size']` -  Defaults to `1024`.
* `node['optoro_kafka']['skip_restart']` -  Defaults to `false`.
* `node['optoro_zfs']['zfs_arc_max']` -  Defaults to `(node['memory']['total'].to_i * 0.05 * 1024).round(0).to_s`.

# Recipes

* [optoro_kafka::default](#optoro_kafkadefault) - Installs and configures kafka
* [optoro_kafka::test](#optoro_kafkatest) - Test recipe.  Sets some helpful defaults etc.

## optoro_kafka::default

 Configures and installs kafka.  We use the exhibitor api to get a list of zookeepers.

TODO: support more than one cluster in a chef environment

## optoro_kafka::test

Test recipe.  Helps set some defualts so we can run our tests.

# License and Maintainer

Maintainer:: Optoro (<devops@optoro.com>)
Source:: https://github.com/optoro-devops/optoro_kafka

License:: MIT
