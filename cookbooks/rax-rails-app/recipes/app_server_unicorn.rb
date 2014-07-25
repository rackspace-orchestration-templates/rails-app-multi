# rubocop:disable Style/LineLength

rails_app_dir = File.join(node['railsstack']['user_home'], node['railsstack']['app_name'], 'current')

node.set['unicorn-ng']['config']['listen'] = 'unix:tmp/sockets/unicorn.sock'

# rubocop:disable Style/AlignParameters
node.set['railsstack']['socket_path'] = File.join(rails_app_dir,
         node['unicorn-ng']['config']['listen'].split(':')[1])
# rubocop:enable Style/AlignParameters

%w(tmp tmp/pids tmp/sockets log).each do |d|
  directory File.join(rails_app_dir, d) do
    owner node['railsstack']['user']
    group node['railsstack']['group']
    action :create
  end
end

unicorn_ng_config File.join(rails_app_dir, 'config', 'unicorn.rb') do
  user node['railsstack']['user']
  working_directory rails_app_dir
  listen node['unicorn-ng']['config']['listen']
  after_fork node['railsstack']['unicorn']['after_fork']
  worker_processes node['railsstack']['unicorn']['workers']
  backlog node['railsstack']['unicorn']['backlog']
end

unicorn_ng_service rails_app_dir do
  service_name 'unicorn'
  cookbook 'rax-rails-app'
  user node['railsstack']['user']
  bundle node['railsstack']['bundle_path']
  environment node['railsstack']['rails']['environment']
end

service 'unicorn' do
  supports restart: true, status: true, reload: true
  action [:enable, :start]
end


include_recipe "rax-rails-app::web_server_nginx"
