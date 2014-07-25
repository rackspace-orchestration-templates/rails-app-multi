# rubocop:disable Style/LineLength
require 'securerandom'

app_name = Chef::Gitrlparse.get_basename(node['railsstack']['git_url'])
default['railsstack']['app_name'] = app_name.empty? ? 'railsapp' : app_name
default['railsstack']['git_deploy_key'] = nil
default['railsstack']['db']['user_id'] = "#{node['railsstack']['app_name']}_user"
default['railsstack']['db']['name'] = "#{node['railsstack']['app_name']}_db"
default['railsstack']['db']['app_user'] = 'railsdbuser'
default['railsstack']['app_server'] = 'unicorn'
default['railsstack']['user'] = 'rails'
default['railsstack']['user_home'] = "/home/#{node['railsstack']['user']}"
default['railsstack']['group'] = node['railsstack']['user']
default['railsstack']['ruby_version'] = '2.1.2'

default['railsstack']['rails']['environment'] = 'production'
default['railsstack']['rails']['rake_tasks'] = ['db:migrate', 'assets:precompile']
default['railsstack']['additional_packages'] = []
default['railsstack']['migrate'] = true
default['railsstack']['bundler'] = true
default['railsstack']['bundler_deployment'] = true
default['railsstack']['precompile_assets'] = true
default['railsstack']['db']['master_role'] = nil
default['railsstack']['db']['hostname'] = nil
default['railsstack']['ruby_manager'] = 'chruby'

default['railsstack']['rails']['secret_key_base'] = nil
