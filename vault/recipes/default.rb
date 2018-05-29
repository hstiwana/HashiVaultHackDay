#
# Cookbook:: vault
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.
 
package 'unzip'

service 'firewalld' do
  action [:stop, :disable]
end

remote_file '/tmp/hashicorp_vault.zip' do
  source 'https://releases.hashicorp.com/vault/0.10.1/vault_0.10.1_linux_amd64.zip'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

execute 'unzip_vault' do
  command 'unzip /tmp/hashicorp_vault.zip -d /usr/local/sbin'
  action :run
  not_if{ File.exist?('/usr/local/sbin/vault') }
end

# execute 'start_vault_dev' do
#   command '/usr/local/sbin/vault server -dev &'
#   action :run
# end

require 'vault'

#ENV['VAULT_ADDR'] = 'http://vault:8200'

Vault.configure do |config|
  config.address = 'http://127.0.0.1:8200'
  config.token = '4a56e816-44e2-37a5-5014-78731727ad09'
end

service 'firewalld' do
  action [:stop, :disable]
end

creds = Vault.logical.read("secret/hello")

template '/etc/test_vault.conf' do
  source 'test_vault.conf.erb'
  owner 'root'
  group 'root'
  mode '0600'
  action :create
  variables(
    first_secret: creds['foo'],
    second_secret: creds['excited']
  )
end
