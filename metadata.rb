name             'elevator'
maintainer       'Joshua Buysse'
maintainer_email 'buysse@umn.edu'
license          'All rights reserved'
description      'Installs/Configures --test-kitchen'
long_description 'Installs/Configures --test-kitchen'
version          '0.7.0'

supports "ubuntu", "14.04"

depends 'iptables'

depends "apt"
depends "apt-upgrade-once"
depends "git"
depends "ntp"
depends "application"
depends "application_php"
depends "php"
depends "apache2"
depends "database"
depends "composer"
depends "beanstalkd"
depends "ssh_known_hosts"
depends "cookbook-shibboleth"
depends "elasticsearch"
depends 'bluepill'
depends "python"
depends 'chef-client'
depends 'tar'
depends 'r'
depends 'L7-redis'
depends 'chef-msttcorefonts'
depends 'zipfile'