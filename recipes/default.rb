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

template "/tmp/.ssh/chef_ssh_deploy_wrapper.sh" do
  source "chef_ssh_deploy_wrapper.sh.erb"
  owner node['myapp']['user']
  mode 0770
end

template "/home/#{node['myapp']['user']}/.ssh/id_rsa.pub" do
  source "id_rsa.pub.erb"
  owner node['myapp']['user']
  mode 0600
end

template "/home/#{node['myapp']['user']}/.ssh/id_rsa" do
  source "id_rsa.erb"
  owner node['myapp']['user']
  mode 0600
end

user_account node['myapp']['user'] do
    ssh_keygen true
end

include_recipe 'git'

package 'httpd'

template "/etc/httpd/conf/httpd.conf" do
  source 'httpd.conf'
end

package 'php'
include_recipe 'composer'

service "httpd" do
  action :restart
end

mysql_service 'default' do
  port '3306'
  version '5.5'
  initial_root_password 'change me'
  action [:create, :start]
end

ssh_known_hosts_entry 'bitbucket.org'
ssh_known_hosts_entry 'github.com'

git "/home/#{node['myapp']['user']}/git" do
	repository node['git']['repo']
	action :sync
end

execute "copy_files" do
    command "sudo cp -R /home/#{node['myapp']['user']}/git/* /var/www/html"
    action :run
end

service "httpd" do
  action :start
end