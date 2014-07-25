
node.set['rvm']['default_ruby'] = node['railsstack']['ruby_version']
node.set['rvm']['gems'] = {
  node['railsstack']['ruby_version'] => [
    {
      'name' => 'bundler'
    }
  ]
}

include_recipe 'rvm::system'

rvm_gem 'rack' do
  ruby_string "ruby-#{node['railsstack']['ruby_version']}@global"
  only_if { node['railsstack']['app_server'] == 'passenger' }
end

node.set['railsstack']['ruby_bin_dir'] =
  File.join('/usr', 'local', 'rvm', 'gems', "ruby-#{node['railsstack']['ruby_version']}@global", 'bin')

%w(bundle ruby).each do |name|
  rvm_wrapper 'deploy' do
    ruby_string "ruby-#{node['railsstack']['ruby_version']}@global"
    binary name
  end
end

node.set['railsstack']['ruby_wrapper'] = "#{File.join('/usr', 'local', 'rvm', 'bin', 'rvm-exec')} #{node['railsstack']['ruby_version']}"

node.set['railsstack']['bundle_path'] = File.join(node['rvm']['root_path'],
                                                  'bin', 'deploy_bundle')

node.set['railsstack']['ruby_path'] = File.join(node['rvm']['root_path'],
                                                'bin', 'deploy_ruby')

node.set['railsstack']['gem_path'] = File.join(node['rvm']['root_path'],
                                               'rubies',
                                               "ruby-#{node['railsstack']['ruby_version']}",
                                               'bin', 'gem')
