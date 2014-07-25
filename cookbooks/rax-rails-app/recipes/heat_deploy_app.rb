####
# fix up attributes that were passed as Heat parameters

# When passed as a parameter from Heat, node['railsstack']['rails']['rake_tasks']
# comes in as a string of space-separated words, but needs to be a list.
node.set['railsstack']['rails']['rake_tasks'] = node['railsstack']['rails']['rake_tasks'].split(' ')

# Heat parameters can't be nil, only an empty string, so convert an
# empty string to nil so logic works as expected.
if node['railsstack']['rails']['db_adapter'].empty?
  node.set['railsstack']['rails']['db_adapter'] = nil
end

if node['railsstack']['git_deploy_key'].empty?
  node.set['railsstack']['git_deploy_key'] = nil
end

####

if platform_family?('debian')
  # required for Ruby >= v2.0.0
  package 'libssl-dev' do
    action :install
  end
end

include_recipe "rax-rails-app::app_host_user"
include_recipe "rax-rails-app::ruby_#{node['railsstack']['ruby_manager']}"

if node['railsstack']['git_url'].empty?
  include_recipe 'rax-rails-app::rails4_base_app'
else
  include_recipe "rax-rails-app::deploy_app"
end

include_recipe "rax-rails-app::app_server_#{node['railsstack']['app_server']}"
