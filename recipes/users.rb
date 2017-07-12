
user 'ubuntu' do
  comment 'A random user'
  home '/home/random'
  shell '/bin/bash'
  password '$1$JJsvHslasdfjVEroftprNn4JHtDi'
  not_if "getent passwd ubuntu"
end






group node['elevator']['group']

user node['elevator']['user'] do
	gid node['elevator']['group']
	home node['elevator']['userhome']
	shell '/bin/bash'
	system true
	supports :manage_home => true
	comment "Elevator user"
end


group node['elevator']['group'] do
  action :modify
  members 'ubuntu'
  append true
end