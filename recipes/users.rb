
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