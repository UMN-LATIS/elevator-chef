name             'elevator'
maintainer       'Joshua Buysse'
maintainer_email 'buysse@umn.edu'
license          'All rights reserved'
description      'Installs/Configures --test-kitchen'
long_description 'Installs/Configures --test-kitchen'
version          '1.0.3'

supports "ubuntu", "16.04"

depends 'iptables', "=2.0.0"

depends "apt", "= 2.9.2"
depends "apt-upgrade-once"
depends "git"
depends "ntp"
depends "application", "= 3.0.0"
depends "application_php", "=2.0.0"
depends "php", '= 3.0.0'
depends "apache2"
depends "database"
depends "composer"
depends "beanstalkd"
depends "ssh_known_hosts"
depends "cookbook-shibboleth"
depends "elasticsearch"
depends 'bluepill', '= 4.0.1'
depends "python"
depends 'chef-client', "=4.3.2"
depends 'tar'
depends 'r', "= 0.3.0"
depends 'L7-redis', "=1.0.7"
depends 'chef-msttcorefonts'
depends 'zipfile'

# pin this version
depends 'windows', '= 1.39.1'