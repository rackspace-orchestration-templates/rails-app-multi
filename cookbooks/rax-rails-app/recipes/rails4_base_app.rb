
require 'securerandom'

node.set_unless['railsstack']['rails']['secret_key_base'] = SecureRandom.hex(64)

case node['platform_family']
when 'rhel'
  commonly_required_packages = [
    'nodejs',            # js execution environment for the execjs gem
    'mysql-devel',       # MySQL client lib for the mysql2 gem
    'ImageMagick-devel', # rmagick gem uses this for image manipulation
    'libicu-devel',      # unicode string handling for charlock-holmes gem
    'postgresql-devel',  # postgres dev libs and headers for postgres gem
    'sqlite-devel'
  ]
when 'debian'
  commonly_required_packages = [
    'nodejs',             # js execution environment for the execjs gem
    'libmysqlclient-dev', # MySQL client lib for the mysql2 gem
    'libmagickwand-dev',  # rmagick gem uses this for image manipulation
    'libicu-dev',         # unicode string handling for charlock-holmes gem
    'libpq-dev',          # postgres dev libs and headers for postgres gem
    'libsqlite3-dev'
  ]
end

pkgs_to_install = commonly_required_packages + node['railsstack']['additional_packages']

pkgs_to_install.each do |pkg|
  package pkg do
    action :install
  end
end

gem_package 'rails' do
  action :install
  version '4.1.2'
  gem_binary node['railsstack']['gem_path']
  only_if { node['railsstack']['ruby_manager'] == 'chruby' }
end

rvm_gem 'rails' do
  version '4.1.2'
  ruby_string "ruby-#{node['railsstack']['ruby_version']}@global"
  only_if { node['railsstack']['ruby_manager'] == 'rvm' }
end

app_dir = File.join(node['railsstack']['user_home'], node['railsstack']['app_name'], 'current')

[ File.join(node['railsstack']['user_home'], node['railsstack']['app_name']), app_dir].each do |dir|
  directory dir do
    action :create
    owner node['railsstack']['user']
    group node['railsstack']['group']
  end
end

rails_new_cmd = <<-EOS
#{node['railsstack']['ruby_wrapper']} -- #{File.join(node['railsstack']['ruby_bin_dir'], 'rails')} new . --skip-bundle
EOS

bash 'rails new' do
  action :run
  cwd app_dir
  user node['railsstack']['user']
  group node['railsstack']['group']
  code rails_new_cmd
  not_if { File.exists?(File.join(app_dir, 'Gemfile')) }
end

bash 'add unicorn to Gemfile' do
  action :run
  cwd app_dir
  user node['railsstack']['user']
  group node['railsstack']['group']
  code %q(echo -e "\ngem 'unicorn'\n" >> Gemfile)
  only_if { node['railsstack']['app_server'] == 'unicorn' }
  not_if %q(grep "^gem 'unicorn'" ./Gemfile), :cwd => app_dir
end

make_secret_command = <<-EOS
cd #{app_dir} && #{node['railsstack']['ruby_wrapper']} -- bundle exec rake secret
EOS

bundle_install_cmd = "#{node['railsstack']['ruby_wrapper']} -- bundle install --path vendor/bundle"

bash 'bundle install' do
  action :run
  cwd app_dir
  environment ({ 'GEM_HOME' => File.join(node['railsstack']['user_home'], '.gem', 'ruby', node['railsstack']['ruby_version']) })
  user node['railsstack']['user']
  group node['railsstack']['group']
  code <<-EOS
  #{bundle_install_cmd}
  EOS
  not_if "#{node['railsstack']['ruby_wrapper']} -- bundle check", :cwd => app_dir
end

rake_tasks = %w(db:migrate assets:precompile)

rake_tasks.each do |task|
  bash "do rake task #{task}" do
    action :run
    user node['railsstack']['user']
    cwd app_dir
    environment 'RAILS_ENV' => node['railsstack']['rails']['environment']
    code <<-EOH
    #{node['railsstack']['ruby_wrapper']} -- bundle exec rake #{task}
    EOH
  end
end
