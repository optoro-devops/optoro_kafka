name 'optoro_kafka'
maintainer 'Optoro'
maintainer_email 'devops@optoro.com'
license 'MIT'
description 'Installs and configures Kafka'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '0.0.5'
supports 'ubuntu', '= 14.04'

depends 'apt'
depends 'cerner_kafka', '~> 1.1.0'
depends 'exhibitor', '~> 0.4.0'
depends 'optoro_zookeeper'

provides 'optoro_kafka::default'
provides 'optoro_kafka::test'

recipe 'optoro_kafka::default', 'Installs and configures kafka'
recipe 'optoro_kafka::test', 'Test recipe.  Sets some helpful defaults etc.'
