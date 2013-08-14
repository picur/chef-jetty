name             'jetty'
maintainer       'Botond Dani'
maintainer_email 'hi@danibotond.ro'
license          'MIT'
description      'Installs/Configures jetty'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

%w{java}.each do |pkg|
	depends		pkg
end

%w{debian ubuntu}.each do |os|
	supports	os
end

recipe 'jetty::default', "Installs and configures Jetty"