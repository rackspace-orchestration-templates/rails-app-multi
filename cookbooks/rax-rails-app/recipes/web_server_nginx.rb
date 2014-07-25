
if platform_family?('rhel')
  node.set['nginx']['user'] = node['railsstack']['user']
end

node.set['nginx']['default_site_enabled'] = false

include_recipe 'nginx'

# The nginx:default_site_enabled attribute boolean doesn't work on rhel-derived
# distros with a package install, so we kill these files directly.
# related upstream PR #230:
# https://github.com/miketheman/nginx/pull/230
if platform_family?('rhel')
  %w(default.conf ssl.conf example_ssl.conf).each do |config|
    file File.join(node['nginx']['dir'], 'conf.d', config) do
      action :delete
    end
  end
end

template File.join(node['nginx']['dir'], 'sites-available', node['railsstack']['app_name']) do
  source 'nginx-site.erb'
  owner 'root'
  group 'root'
  mode 0644
end

nginx_site node['railsstack']['app_name'] do
  template nil
  notifies :reload, 'service[nginx]'
end
