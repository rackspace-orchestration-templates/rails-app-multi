include_recipe 'chef-sugar'

rails_app_dir = File.join(node['railsstack']['user_home'], node['railsstack']['app_name'], 'current')

directory File.join(rails_app_dir, 'tmp') do
  owner node['railsstack']['user']
  group node['railsstack']['group']
  action :create
end

node.set['passenger']['install_method'] = 'source'
node.set['passenger']['ruby_bin'] = node['railsstack']['ruby_path']

ohai 'reload for new ruby gems dir' do
  action :reload
end

gem_package 'rack' do
  action :install
  gem_binary node['railsstack']['gem_path']
end

include_recipe 'passenger_apache2'

web_app node['railsstack']['app_name'] do
  cookbook 'rax-rails-app'
  docroot File.join(rails_app_dir, 'public')
  if cloud?
    if vagrant?
      server_name node['ipaddress']
    else
      server_name node['cloud']['local_ipv4']
    end
  else
    server_name node['cloud']['public_ipv4']
  end
  server_aliases [node['railsstack']['app_name'], node['hostname']]
  rails_env node['railsstack']['rails']['environment']
  secret_key_base node['railsstack']['rails']['secret_key_base']
end
