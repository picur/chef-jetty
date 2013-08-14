#
# Cookbook Name:: jetty
# Attributes:: default
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

# use JDK 7 as default
override['java']['jdk_version'] = 7

# defines jetty defaults
default['jetty']['host']			= '0.0.0.0'
default['jetty']['port']			= 8080
default['jetty']['no_start']		= 0
default['jetty']['jetty_args']		= "jetty.port=#{node[:jetty][:port]}"
default['jetty']['java_options']	= '-Xmx256m -Djava.awt.headless=true'

default['jetty']['version'] = '9.0.4.v20130625'
default['jetty']['source'] 	= "http://eclipse.org/downloads/download.php?file=/jetty/#{node['jetty']['version']}/dist/jetty-distribution-#{node['jetty']['version']}.tar.gz&r=1"

case platform
when 'debian', 'ubuntu'
	default['jetty']['user']		= 'jetty'
	default['jetty']['group']		= 'jetty'
	default['jetty']['home']		= '/usr/share/jetty'
	default['jetty']['log_dir']		= '/var/log/jetty'
	default['jetty']['config_dir']	= '/etc/jetty'
	default['jetty']['tmp_dir']		= '/var/cache/jetty/data'
	default['jetty']['context_dir']	= '/etc/jetty/contexts'
	default['jetty']['webapp_dir']	= '/var/lib/jetty/webapps'
end