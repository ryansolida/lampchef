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

execute "make_dir" do
	command "mkdir /tmp/.ssh"
	not_if { ::File.directory?("/tmp/.ssh") }
end

file "/root/.ssh/id_rsa" do
  keys = data_bag_item('ssh', 'key')
  content keys['private']
  owner node['myapp']['user']
  mode 0600
  action :create
end

file "/root/.ssh/id_rsa.pub" do
  keys = data_bag_item('ssh', 'key')
  content keys['public']
  owner node['myapp']['user']
  mode 0700
  action :create
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

git "/root/git" do
	repository node['git']['repo']
	action :sync
end

execute "copy_files" do
    command "sudo cp -R /root/git/* /var/www/html"
    action :run
end

service "httpd" do
  action :start
end