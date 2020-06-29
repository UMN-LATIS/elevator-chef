
# bluepill reads this path wrong because it assumes gems go into the same dir as ruby
default['bluepill']['bin'] = "/opt/chef/embedded/bin/bluepill"


default['elevator']['upgrade_chef'] = false

default['elevator']['git']['repository'] = 'https://github.com/cmcfadden/elevator.git'
default['elevator']['git']['ref'] = 'master'

default['elevator']['imagemagick']['path'] = 'https://www.imagemagick.org/download/releases/ImageMagick-7.0.5-10.tar.xz'
default['elevator']['imagemagick']['version'] = '7.0.5-10'

default['elevator']['install_directory'] = '/opt/elevator'

default['elevator']['user'] = 'elevator'
default['elevator']['group'] = 'elevator'
default['elevator']['userhome'] = "/var/lib/elevator"

default['elevator']['db']['driver'] = 'postgre'
default['elevator']['db']['doctrine_driver'] = 'pod_pgsql'
default['elevator']['db']['hostname'] = '127.0.0.1'
default['elevator']['db']['port'] = '5432'
default['elevator']['db']['username'] = 'root'
default['elevator']['db']['password'] = 'pa55w0rd'
default['elevator']['db']['database'] = 'elevator'
default['elevator']['db']['dbprefix'] = ''

default['elevator']['elasticsearch']['hostname'] = 'localhost'
default['elevator']['elasticsearch']['port'] = '9200'
default['elevator']['elasticsearch']['index'] = 'elevator'
default['elevator']['elasticsearch']['version'] = '5.5.0'

default['elevator']['redis']['hostname'] = 'localhost'
default['elevator']['redis']['port'] = '6379'
default['elevator']['beanstalkd']['hostname'] = 'localhost'

default['elevator']['config']['web_hostname'] = 'localhost'
default['elevator']['config']['base_url'] = "http://localhost/"
### the following value is not suitable for production, development only
### 0 - no logs, 1 - errors, 2 - debug, 3 - informational, 4 - all
default['elevator']['config']['log_threshold'] = '1'
# blank is default, leaves in application/logs directory
# for production, recommend moving elsewhere and ensuring directory
# is writable by web server.
default['elevator']['config']['log_path'] = ''
# blank is default, leaves in system/cache directory
# for prod, may want to redirect to instance storage for performance
default['elevator']['config']['cache_path'] = ''
# used for session store encryption, should not be left at default
# for any production deploy.
default['elevator']['config']['encryption_key'] = 'fdsafdsafdsafsdafsd4512352'
# internal scratch directory -- prod should point to instance store
default['elevator']['config']['scratchspace'] = '/scratch'

default['elevator']['config']['email']['smtphost'] = ''

# binaries.  By default, assume in default path.
default['elevator']['config']['binaries']['blender'] = '/usr/local/bin/blender'
default['elevator']['config']['binaries']['ffmpeg'] = '/usr/local/bin/ffmpeg'
default['elevator']['config']['binaries']['ffprobe'] = '/usr/local/bin/ffprobe'
default['elevator']['config']['binaries']['yamdi'] = 'yamdi'
default['elevator']['config']['binaries']['qtfaststart'] = 'qtfaststart'
default['elevator']['config']['binaries']['convert'] = '/usr/local/bin/convert'
default['elevator']['config']['binaries']['gifsicle'] = 'gifsicle'
default['elevator']['config']['binaries']['meshlabPath'] = '/usr/local/bin/meshlab'
default['elevator']['config']['binaries']['nxsbuild_dir'] = '/usr/local/bin/nxsbuild'
default['elevator']['config']['binaries']['nxsedit_dir'] = '/usr/local/bin/nxsedit'
default['elevator']['config']['binaries']['rtibuild_dir'] = '/usr/local/bin/rtibuild'
default['elevator']['config']['binaries']['vipsPath'] = '/usr/local/bin/vips'
default['elevator']['config']['binaries']['gnuPlot'] = '/usr/local/bin/gnuplot'
default['elevator']['config']['binaries']['pypdfocr'] = '/usr/local/bin/ocrmypdf'
default['elevator']['config']['binaries']['spatialMedia'] = '/usr/local/bin/spatial'
default['elevator']['config']['binaries']['shrinkpdf'] = '/usr/local/bin/shrinkpdf'
default['elevator']['config']['binaries']['pdfinfo'] = '/usr/local/bin/pdfinfo'
default['elevator']['config']['binaries']['pdftotext'] = '/usr/local/bin/pdftotext'
default['elevator']['config']['binaries']['mogrify'] = '/usr/local/bin/mogrify'
default['elevator']['config']['binaries']['montage'] = '/usr/local/bin/montage'
default['elevator']['config']['binaries']['identify'] = '/usr/local/bin/identify'


# TODO: include options for XSS filtering and CSRF token

# valid is TRUE or FALSE, since it's PHP tokens.  Default is FALSE,
# should test with TRUE
default['elevator']['config']['compress_output'] = 'FALSE'

# if a reverse proxy is used (ELB or similar), put IP addresses in this
# field, comma separated so that X-FORWARDED-FOR is trusted from those
# addresses
default['elevator']['config']['proxy_ips'] = ''

default['elevator']['fakeshib'] = true
default['elevator']['php_short_open_tag'] = true

default['elevator']['deploy_environment'] = "development"

default['elevator']['config']['shibboleth']['login'] = "";
default['elevator']['config']['shibboleth']['logout'] = "";

default['elevator']['config']['shibboleth']['enableShibboleth'] = "false";
default['elevator']['config']['shibboleth']['shibbolethPath'] = "";

# LDAP configuration.
default['elevator']['config']['ldap']['username'] = ""
default['elevator']['config']['ldap']['password'] = ""
default['elevator']['config']['ldap']['uri'] = ""
default['elevator']['config']['ldap']['search_base'] = "ou=People,o=University of Minnesota,c=US"
default['elevator']['config']['authHelper'] = "authHelper"

default['elevator']['config']['oAuthClient'] = ""
default['elevator']['config']['oAuthSecret'] = ""
default['elevator']['config']['oAuthApplication'] = ""
default['elevator']['config']['oAuthDomain'] = ""

default['elevator']['config']['oAuthDelegate']['type'] = ""
default['elevator']['config']['oAuthDelegate']['project_id'] = ""
default['elevator']['config']['oAuthDelegate']['private_key_id'] = ""
default['elevator']['config']['oAuthDelegate']['private_key'] = ""
default['elevator']['config']['oAuthDelegate']['client_email'] = ""
default['elevator']['config']['oAuthDelegate']['client_id'] = ""
default['elevator']['config']['oAuthDelegate']['auth_uri'] = ""
default['elevator']['config']['oAuthDelegate']['token_uri'] = ""
default['elevator']['config']['oAuthDelegate']['auth_provider_x509_cert_url'] = ""
default['elevator']['config']['oAuthDelegate']['client_x509_cert_url'] = ""

default['elevator']['config']['labels']['remoteLogin'] = "University"
default['elevator']['config']['labels']['guestLogin'] = "Guest"


default['elevator']['config']['jwplayer'] = ""
default['elevator']['config']['googleapi'] = ""
default['elevator']['config']['apiKey'] = ""
default['elevator']['config']['apiSecret'] = ""
default['elevator']['config']['css_override'] = 'FALSE'
default['elevator']['config']['restrict_hidden_assets'] = 'FALSE'


default['elevator']['containers']['ffmpeg']['version'] = "latest"
default['elevator']['containers']['ffmpeg']['command'] = ["ffmpeg", "MP4Box", "ffprobe"]
default['elevator']['containers']['vips']['version'] = "latest"
default['elevator']['containers']['exiftool']['version'] = "latest"
default['elevator']['containers']['rtibuild']['version'] = "latest"
default['elevator']['containers']['r-lang']['version'] = "latest"
default['elevator']['containers']['pdfutils']['version'] = "latest"
default['elevator']['containers']['pdfutils']['command'] = ["ocrmypdf", "shrinkpdf", "pdftotext","pdfinfo"]
default['elevator']['containers']['openoffice']['version'] = "latest"
default['elevator']['containers']['nxsbuild']['version'] = "latest"
default['elevator']['containers']['meshlab']['version'] = "latest"
default['elevator']['containers']['imagemagick']['version'] = "latest"
default['elevator']['containers']['imagemagick']['command'] = ["convert", "identify", "mogrify", "montage"]
default['elevator']['containers']['exiftool']['version'] = "latest"
default['elevator']['containers']['blender']['version'] = "latest"
default['elevator']['containers']['spatial']['version'] = "latest"
default['elevator']['containers']['gnuplot']['version'] = "latest"
default['elevator']['containers']['gltf']['version'] = "latest"
default['elevator']['containers']['gltf']['command'] = ["obj2gltf", "gltf-pipeline"]