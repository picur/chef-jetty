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

jetty_archive = "#{Chef::Config[:file_cache_path]}/jetty-distribution-#{node[:jetty][:version]}.tar.gz"
current_version = execute "head -n 1 #{node[:jetty][:home]}/VERSION.txt | cut -d ' ' -f 1 | cut -d '-' -f 2"

remote_file jetty_archive do
	action :create_if_missing
	source node[:jetty][:source]
	not_if { node[:jetty][:version].eql?(current_version.to_s) }
end

directory node[:jetty][:home] do
	action :delete
	recursive true
	not_if { node[:jetty][:version].eql?(current_version.to_s) }
end

# create jetty user
group node[:jetty][:group]
user node['jetty']['user'] do
	comment 'Jetty User'
	home node['jetty']['home']
	gid node['jetty']['group']
	shell '/bin/false'
	action :create
end

bash "install_jetty" do
	cwd "/usr/share"
	code <<-EOH
		tar -xzf #{jetty_archive}
		mv jetty-distribution-#{node[:jetty][:version]} jetty
		rm -rf jetty/{webapps,logs,webapps.demo}
		EOH
	only_if { ::File.exists?(jetty_archive) }
end

directory node[:jetty][:tmp_dir] do
	owner node[:jetty][:user]
	group node[:jetty][:group]
	mode 0755
	action :create
	recursive true
end

directory node[:jetty][:webapp_dir] do
	owner node[:jetty][:user]
	group node[:jetty][:group]
	mode 0755
	action :create
	recursive true
end

directory node[:jetty][:log_dir] do
	owner node[:jetty][:user]
	group node[:jetty][:group]
	mode 0755
	action :create
	recursive true
end

link "#{node[:jetty][:config_dir]}" do
	to "#{node[:jetty][:home]}/etc"
	link_type :symbolic
	action :create
end

link "#{node[:jetty][:home]}/webapps" do
	to node[:jetty][:webapp_dir]
	link_type :symbolic
end

link "/etc/init.d/jetty" do
	to "#{node[:jetty][:home]}/bin/jetty.sh"
	link_type :symbolic
	only_if { ::File.exists?("#{node[:jetty][:home]}/bin/jetty.sh") }
end

bash "change_permissions" do
	code <<-EOH
		chown -R #{node[:jetty][:user]}:#{node[:jetty][:group]} #{node[:jetty][:home]}
		chown -R #{node[:jetty][:user]}:#{node[:jetty][:group]} #{node[:jetty][:webapp_dir]}
		chown -R #{node[:jetty][:user]}:#{node[:jetty][:group]} #{node[:jetty][:tmp_dir]}
		chmod -R 0755 #{node[:jetty][:home]}
		chmod -R 0755 #{node[:jetty][:webapp_dir]}
		chmod -R 0755 #{node[:jetty][:tmp_dir]}
		EOH
end

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

%w{jetty.conf jetty.xml jetty-logging.xml}.each do |conf|
	template "#{node[:jetty][:config_dir]}/#{conf}" do
	  source "#{conf}.erb"
	  owner node[:jetty][:user]
	  group node[:jetty][:group]
	  mode "0755"
	  notifies :restart, "service[jetty]", :delayed
	end
end