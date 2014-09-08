#
# Cookbook Name:: apache
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

package "httpd" do
    action :install
end

template "/etc/httpd/conf/httpd.conf" do
    source "httpd.conf.erb"
    owner "root"
    group "root"
    mode 0644
    notifies :reload, "service[httpd]"
end

service "httpd" do
    supports :status => true, :restart => true, :reload => true
    action [:enable, :start]
end

