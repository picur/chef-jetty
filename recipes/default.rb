#
# Cookbook Name:: jetty
# Recipe:: default
#
# Copyright 2013, Botond Dani
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

include_recipe 'java'

remote_file "#{Chef::Config[:file_cache_path]}/jetty-distribution-#{node[:jetty][:version]}.tar.gz" do
	action :create_if_missing
	source node[:jetty][:source]
end

bash "install_jetty" do
	cwd "/usr/share"
	code <<-EOH
		mkdir -p #{node[:jetty][:webapp_dir]}
		mkdir -p #{node[:jetty][:tmp_dir]}

		tar -xzf #{Chef::Config[:file_cache_path]}/jetty-distribution-#{node[:jetty][:version]}.tar.gz
		mv jetty-distribution-#{node[:jetty][:version]} jetty
		cp #{node[:jetty][:home]}/bin/jetty.sh /etc/init.d/jetty
		EOH
	only_if { ::File.exists?("#{Chef::Config[:file_cache_path]}/jetty-distribution-#{node[:jetty][:version]}.tar.gz") }
end

link "#{node[:jetty][:home]}/etc" do
	to node[:jetty][:config_dir]
end

link "#{node[:jetty][:home]}/logs" do
	to node[:jetty][:log_dir]
end

%w{node[:jetty][:home] node[:jetty][:tmp_dir] node[:jetty][:webapp_dir]}.each do |d|
	execute "chown -R #{node[:jetty][:user]}:#{node[:jetty][:group]} #{d}"
	execute "chmod -R 0755 #{d}"
end

# create jetty user
user node['jetty']['user'] do
	comment 'Jetty User'
	home node['jetty']['home']
	gid node['jetty']['group']
	shell '/bin/false'
	action :create
end

# create jetty service
service "jetty" do
	case node["platform"]
	when "debian", "ubuntu"
		service_name "jetty"
		action [:enable, :start]
	end
end

template "/etc/default/jetty" do
  source "default_jetty.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[jetty]", :delayed
end

template "#{node[:jetty][:config_dir]}/jetty.xml" do
  source "jetty.xml.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[jetty]", :delayed
end