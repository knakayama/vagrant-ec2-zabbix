#
# Cookbook Name:: zabbix
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

# add zabbix 2.2 yum repository
remote_file "#{Chef::Config[:file_cache_path]}/#{node['zabbix']['repo-name']}" do
   source "#{node['zabbix']['repo-url']}"
end

rpm_package "add zabbix repo" do
    source "#{Chef::Config[:file_cache_path]}/#{node['zabbix']['repo-name']}"
    action :install
end

%w{
    zabbix-server-mysql
    zabbix
    zabbix-server
}.each do |pkg|
    package pkg do
        action :install
    end
end

bash "create zabbix tables" do
    user "ec2-user"
    group "ec2-user"
    cwd "/usr/share/doc/zabbix-server-mysql-2.2.6/create"
    code <<-EOT
        cat schema.sql images.sql data.sql | mysql -uzabbix --password='#{node['ZABBIX_PASSWORD']}' zabbix
    EOT
    not_if "mysql -uroot -D zabbix -e 'show tables'"
end

template "/etc/zabbix/zabbix_server.conf" do
    source "zabbix_server.conf.erb"
    owner "root"
    group "zabbix"
    mode 00540
    notifies :restart, "service[zabbix-server]"
end

service "zabbix-server" do
    action [:enable, :start]
    supports :status => true, :restart => true, :reload => true
end

%w{
    zabbix-web-mysql
    zabbix-web
    mod24_ssl
}.each do |pkg|
    package pkg do
        action :install
    end
end

template "/etc/httpd/conf.d/zabbix.conf" do
    source "zabbix.conf.erb"
    owner "root"
    group "root"
    mode 00644
    notifies :restart, "service[httpd]"
end

bash "create htpasswd file" do
    user "root"
    code <<-EOT
        htpasswd -bc /etc/httpd/conf.d/passwd "#{node['HTPASSWD_USER']}" "#{node['HTPASSWD_PASS']}"
    EOT
    not_if { File.exist?("/etc/httpd/conf.d/passwd") }
end

bash "create private key" do
    user "root"
    code <<-EOT
        openssl req -new -newkey rsa:2048 -sha1 -x509 -nodes \
            -set_serial 1 \
            -days 365 \
            -subj "/C=JP/ST=Tokyo/L=Tokyo City/CN=#{node["DOMAIN"]}" \
            -out /etc/pki/tls/certs/#{node["DOMAIN"]}.crt \
            -keyout /etc/pki/tls/private/#{node["DOMAIN"]}.key
        chmod 00400 /etc/pki/tls/private/#{node["DOMAIN"]}.key
    EOT
    not_if { File.directory?("/etc/pki/tls/ssl.key") }
end

service "httpd" do
    action [:enable, :start]
    supports :status => true, :restart => true, :reload => true
end

