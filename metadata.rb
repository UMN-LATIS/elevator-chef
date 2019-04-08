name             'elevator'
maintainer       'Joshua Buysse'
maintainer_email 'buysse@umn.edu'
license          'All rights reserved'
description      'Installs/Configures --test-kitchen'
long_description 'Installs/Configures --test-kitchen'
version          '1.0.4'

supports "ubuntu", "16.04"

depends 'iptables', "=2.0.0"

depends "apt", "~> 7.1.1"
depends "apt-upgrade-once"
depends "git"
depends "ntp"
depends "php"
depends "apache2"
depends "acme", "4.0.0"
depends "composer"
depends "beanstalkd", "= 0.3.2"
depends "ssh_known_hosts"
depends "cookbook-shibboleth"
depends "elasticsearch", "= 3.2.1"
depends 'bluepill'
depends 'chef-client', "= 11.1.2"
depends 'tar'
depends 'r', '~> 0.4.0'
depends 'L7-redis', "=1.0.7"
depends 'chef-msttcorefonts'
depends 'zipfile'
depends "poise-python"
depends "chef_client_updater", "~> 3.5.2"
