#
# Cookbook Name:: opsworks-lineman-rails
# Recipe:: default
#
# Copyright (C) 2014 YOUR_NAME
#
# All rights reserved - Do Not Redistribute
#

node[:deploy].each do |application, deploy|
  File.new('/srv/www/foo.txt', 'w')
end
