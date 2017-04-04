name             'elevator'
maintainer       'Joshua Buysse'
maintainer_email 'buysse@umn.edu'
license          'All rights reserved'
description      'Installs/Configures --test-kitchen'
long_description 'Installs/Configures --test-kitchen'
version          '1.0.0'

supports "ubuntu", "14.04"

depends 'iptables', "=2.0.0"

depends "apt"
depends "apt-upgrade-once"
depends "git"
depends "ntp"
depends "application", "= 3.0.0"
depends "application_php", "=2.0.0"
depends "php"
depends "apache2"
depends "database"
depends "composer"
depends "beanstalkd", "=0.1.5"
depends "ssh_known_hosts"
depends "cookbook-shibboleth"
depends "elasticsearch", "= 1.2.0"
depends 'bluepill', "= 2.4.0"
depends "python"
depends 'chef-client'
depends 'tar'
depends 'r'
depends 'L7-redis', "=1.0.7"
depends 'chef-msttcorefonts'
depends 'zipfile'