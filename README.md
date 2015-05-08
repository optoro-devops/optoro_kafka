# Description

Installs and configures Kafka

# Requirements

## Platform:

* Ubuntu (= 14.04)

## Cookbooks:

* apt
* aws
* optoro_zfs
* cerner_kafka (~> 1.1.0)
* exhibitor (~> 0.4.0)
* optoro_zookeeper

# Attributes

* `node['kafka']['brokers']` -  Defaults to `[ ... ]`.
* `node['kafka']['lib_jars']` -  Defaults to `[ ... ]`.
* `node['kafka']['zookeepers']` -  Defaults to `[ ... ]`.
* `node['kafka']['env_vars']['KAFKA_HEAP_OPTS']` -  Defaults to `"-Xmx1G -Xms1G"`.
* `node['exhibitor']['base_domain']` -  Defaults to `exhibitor.optoro.io`.
* `node['kafka']['server.properties']['log.dirs']` -  Defaults to `/kafka`.
* `node['kafka']['scala_version']` -  Defaults to `2.10`.
* `node['kafka']['version']` -  Defaults to `0.8.2.1`.
* `node['optoro_kafka']['disks']` -  Defaults to `[ ... ]`.
* `node['optoro_kafka']['disk_size']` -  Defaults to `1024`.

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

License:: MIT
