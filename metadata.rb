name             'elevator'
maintainer       'Joshua Buysse'
maintainer_email 'buysse@umn.edu'
license          'All rights reserved'
description      'Installs/Configures --test-kitchen'
long_description 'Installs/Configures --test-kitchen'
version          '1.1.2'

supports "ubuntu", "20.04"

depends 'iptables', "=2.0.0"

depends "apt", "~> 7.1.1"
depends "apt-upgrade-once", "0.2.1"
depends "git", "9.0.1"
depends "ntp", "1.8.6"
depends "php", "8.0.0"
depends "apache2", "3.3.1"
depends "acme", "4.1.2"
depends "composer", "2.2.0"
depends "beanstalkd", "= 0.3.2"
depends "ssh_known_hosts", "6.2.0"
depends "cookbook-shibboleth", "0.7.4"
depends "elasticsearch", "= 3.4.10"
depends 'bluepill', "4.1.1"
depends 'chef-client', "= 12.2.0"
depends 'tar', "0.7.0"
# depends 'r', '~> 0.4.0'
depends 'L7-redis', "=1.0.7"
#depends 'chef-msttcorefonts', "0.9.0"
depends 'zipfile', "0.1.0"
depends "poise-python", "1.7.0"
depends "chef_client_updater", "~> 3.5.2"

depends 'docker', '~> 6.0.3'

