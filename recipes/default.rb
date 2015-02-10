#
# Cookbook Name:: cheftest
# Recipe:: default
#
# Copyright (C) 2015 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

group node['myapp']['group']

user node['myapp']['user'] do
  group node['myapp']['user']
  system true
  shell '/bin/bash'
end

include_recipe 'git'


package 'httpd'

#file '/etc/httpd/conf/httpd.conf' do
#  content ::File.open('httpd.conf').read
#end

template "/etc/httpd/conf/httpd.conf" do
  source 'httpd.conf'
end


package 'php'
include_recipe 'composer'

service "httpd" do
  action :restart
end

file '/var/www/html/index.php' do
 content '<?= phpinfo(); ?>'
end

mysql_service 'default' do
  port '3306'
  version '5.5'
  initial_root_password 'change me'
  action [:create, :start]
end

execute "bitbucket_host" do
	command "touch ~/.ssh/config && echo -e \"Host bitbucket.org\n\tStrictHostKeyChecking no\n\" >> ~/.ssh/config"
end

git "/home/vagrant/git" do
	repository "git@bitbucket.org:benlipp/git-serve-test.git"
	action :sync
end

execute "copy_files" do
    command "sudo cp -R /home/vagrant/git/* /var/www/html"
    action :run
  end


service "httpd" do
  action :start
end