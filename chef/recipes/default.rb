#
# Cookbook:: chef
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

require 'vault'

#ENV['VAULT_ADDR'] = 'http://vault:8200'

Vault.configure do |config|
  config.address = 'http://vault:8200'
  config.token = '3d5b2633-f8cb-029e-780e-7685a54303df'
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
