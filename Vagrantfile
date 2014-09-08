# -*- mode: ruby -*-
# vim: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.box     = "ec2"
    config.vm.box_url = "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"
    config.vm.synced_folder ".", "/vagrant", disabled: true

    config.vm.provider :aws do |aws, override|
        override.ssh.username         = ENV["AWS_SSH_USERNAME"]
        override.ssh.private_key_path = ENV["AWS_SSH_KEY_PATH"]
        override.ssh.pty              = false

        aws.access_key_id     = ENV["AWS_ACCESS_KEY_ID"]
        aws.secret_access_key = ENV["AWS_SECRET_ACCESS_KEY"]
        aws.keypair_name      = ENV["AWS_KEYPAIR_NAME"]
        aws.region            = "ap-northeast-1"
        aws.ami               = ENV["AMI"]
        aws.instance_type     = ENV["INSTANCE_TYPE"]
        aws.security_groups   = [ENV["AWS_SECURITY_GROUP"]]
        aws.tags              = {
            "Name"        => "ec2-zabbix",
            "Description" => "zabbix monitoring server",
        }
        aws.elastic_ip        = ENV["ELASTIC_IP"]
        aws.user_data         = <<EOT
#!/bin/sh
echo "Defaults    !requiretty" > /etc/sudoers.d/vagrant-init
chmod 440 /etc/sudoers.d/vagrant-init
ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
sed -i -e 's@"UTC"@"Asia/Tokyo"@' -e 's/true/false/' /etc/sysconfig/clock
mkdir -p /etc/chef/ohai/hints
touch /etc/chef/ohai/hints/ec2.json
yum -y update
EOT
    end

    #config.vm.provision "shell", inline: $script

    # install or update chef
    config.omnibus.chef_version = :latest

    # chef-solo
    config.vm.provision :chef_solo do |chef|
        chef.custom_config_path = "Vagrantfile.chef"
        chef.cookbooks_path = ["site-cookbooks"]
        chef.data_bags_path = "data_bags"
        chef.json = {
            "DOMAIN"          => ENV["DOMAIN"],
            "HOSTNAME"        => ENV["HOSTNAME"],
            "ZABBIX_PASSWORD" => ENV["ZABBIX_PASSWORD"],
            "HTPASSWD_USER"   => ENV["HTPASSWD_USER"],
            "HTPASSWD_PASS"   => ENV["HTPASSWD_PASS"],
        }
        chef.run_list = %w[
            recipe[aws-linux-common]
            recipe[postfix]
            recipe[mysql]
            recipe[zabbix]
        ]
    end
end
