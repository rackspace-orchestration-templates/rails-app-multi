# rubocop:disable Style/LineLength

case node['platform_family']
when 'rhel'
  commonly_required_packages = [
    'nodejs',            # js execution environment for the execjs gem
    'mysql-devel',       # MySQL client lib for the mysql2 gem
    'ImageMagick-devel', # rmagick gem uses this for image manipulation
    'libicu-devel',      # unicode string handling for charlock-holmes gem
    'postgresql-devel'   # postgres dev libs and headers for postgres gem
  ]
when 'debian'
  commonly_required_packages = [
    'nodejs',             # js execution environment for the execjs gem
    'libmysqlclient-dev', # MySQL client lib for the mysql2 gem
    'libmagickwand-dev',  # rmagick gem uses this for image manipulation
    'libicu-dev',         # unicode string handling for charlock-holmes gem
    'libpq-dev'           # postgres dev libs and headers for postgres gem
  ]
end

pkgs_to_install = commonly_required_packages + node['railsstack']['additional_packages']

application node['railsstack']['app_name'] do
  packages pkgs_to_install
  path File.join(node['railsstack']['user_home'], node['railsstack']['app_name'])
  owner node['railsstack']['user']
  group node['railsstack']['group']
  repository node['railsstack']['git_url']
  revision node['railsstack']['git_revision']
  deploy_key node['railsstack']['git_deploy_key'] if node['railsstack']['git_deploy_key']
  environment_name node['railsstack']['rails']['environment']
  migrate node['railsstack']['migrate']

  rails do
    bundle_command "#{node['railsstack']['ruby_wrapper']} -- #{node['railsstack']['bundle_path']}"
    bundler node['railsstack']['bundler']
    bundler_deployment node['railsstack']['bundler_deployment']
    precompile_assets node['railsstack']['precompile_assets']
    database_master_role node['railsstack']['db']['master_role']
    db_type = node['railsstack']['db']['type']
    db_name = node['railsstack']['db']['name']
    db_hostname = node['railsstack']['db']['hostname']
    db_user_id = node['railsstack']['db']['user_id']
    db_user_pass = node['railsstack']['db']['user_password']
    db_adapter = node['railsstack']['rails']['db_adapter'] || db_type
    database do
      adapter db_adapter
      database db_name
      host db_hostname if db_hostname
      username db_user_id
      password db_user_pass
    end

  end

  before_restart do
    node['railsstack']['rails']['rake_tasks'].each do |task|
      bash "do_extra_rake_task_#{task}" do
        action :run
        user node['railsstack']['user']
        cwd File.join(node['railsstack']['user_home'], node['railsstack']['app_name'], 'current')
        environment 'RAILS_ENV' => node['railsstack']['rails']['environment']
        code <<-EOH
        #{node['railsstack']['ruby_wrapper']} -- #{node['railsstack']['bundle_path']} exec rake #{task}
        EOH
      end
    end
  end

  restart_command do
    service 'unicorn' do
      action :restart
      only_if { File.exist?('/etc/init.d/unicorn') }
    end

    file File.join(node['railsstack']['user_home'],
                   node['railsstack']['app_name'],
                   'current', 'tmp', 'restart.txt') do
      action :touch
      only_if { node['railsstack']['app_server'] == 'passenger' }
    end
  end

end
