default["zabbix"]["version"]   = "2.2"
default["zabbix"]["repo-name"] = "zabbix-release-#{default['zabbix']['version']}-1.el6.noarch.rpm"
default["zabbix"]["repo-url"]  = "http://repo.zabbix.com/zabbix/#{default['zabbix']['version']}/rhel/6/x86_64/#{default['zabbix']['repo-name']}"
default["ZABBIX_PASSWORD"]     = ENV["ZABBIX_PASSWORD"]
default["HTPASSWD_USER"]       = ENV["HTPASSWD_USER"]
default["HTPASSWD_PASS"]       = ENV["HTPASSWD_PASS"]
default["DOMAIN"]              = ENV["DOMAIN"]

