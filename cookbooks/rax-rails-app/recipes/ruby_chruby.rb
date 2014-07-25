
node.set['chruby']['rubies'] = {
  '1.9.3-p392' => false,
  node['railsstack']['ruby_version'] => true }

node.set['chruby']['default'] = node['railsstack']['ruby_version']

include_recipe 'chruby::system'

node.set['railsstack']['ruby_bin_dir'] =
  File.join('/opt', 'rubies', node['railsstack']['ruby_version'], 'bin')

gem_package 'bundler' do
  action :install
  gem_binary File.join(node['railsstack']['ruby_bin_dir'], 'gem')
end

if platform_family?('rhel')
  node.override['unicorn-ng']['service']['wrapper'] = "/usr/local/bin/chruby-exec #{node['chruby']['default']}"
end

node.set['railsstack']['ruby_wrapper'] = "/usr/local/bin/chruby-exec #{node['railsstack']['ruby_version']}"
node.set['railsstack']['bundle_path'] = File.join(node['railsstack']['ruby_bin_dir'], 'bundle')
node.set['railsstack']['ruby_path'] = File.join(node['railsstack']['ruby_bin_dir'], 'ruby')
node.set['railsstack']['gem_path'] = File.join(node['railsstack']['ruby_bin_dir'], 'gem')
