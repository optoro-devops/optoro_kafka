name 'optoro_kafka'
maintainer 'Optoro'
maintainer 'devops@optoro.com'
license 'MIT'
description 'Installs and configures Kafka'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.0.3'

depends 'apt'
depends 'cerner_kafka'
depends 'exhibitor'
depends 'optoro_zookeeper'
