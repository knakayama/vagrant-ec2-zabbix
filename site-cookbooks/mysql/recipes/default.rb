#
# Cookbook Name:: mysql
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

package "mysql-server" do
    action :install
end

template "/etc/my.cnf" do
    source "my.cnf.erb"
    owner "root"
    group "root"
    mode 00644
    notifies :restart, "service[mysqld]"
end

service "mysqld" do
    supports :reload => true, :restart => true, :status => true
    action [:enable, :start]
end

bash "create zabbix database" do
    user "ec2-user"
    group "ec2-user"
    code <<-EOT
        mysql -uroot -e "create database zabbix character set utf8;"
    EOT
    not_if "[ -d /var/lib/mysql/zabbix ]"
end

bash "create zabbix user on mysql" do
    user "ec2-user"
    group "ec2-user"
    code <<-EOT
        mysql -uroot -e "grant all privileges on zabbix.* to 'zabbix'@'localhost' identified by '#{node['ZABBIX_PASSWORD']}';"
    EOT
    not_if "mysql -uroot -e 'select User from mysql.user' | grep -qF 'zabbix'"
end

