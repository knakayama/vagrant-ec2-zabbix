#
# Cookbook Name:: postfix
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

template "/etc/postfix/main.cf" do
    source "main.cf.erb"
    owner "root"
    group "root"
    mode 00644
    notifies :reload, "service[postfix]"
end

service "postfix" do
    supports :status => true, :restart => true, :reload => true
    action [:enable, :start]
end

