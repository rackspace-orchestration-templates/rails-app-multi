
include_recipe 'mysql::server'

include_recipe 'database::mysql'

connection_info = {
  host: 'localhost',
  username: 'root',
  password: node['mysql']['server_root_password']
}

mysql_database node['railsstack']['db']['name'] do
  connection connection_info
  action :create
end

mysql_database_user node['railsstack']['db']['user_id'] do
  connection connection_info
  password node['railsstack']['db']['user_password']
  host '%'
  action :create
end

mysql_database_user node['railsstack']['db']['user_id'] do
  connection connection_info
  database_name node['railsstack']['db']['name']
  privileges [:delete, :alter, :index, :create, :select, :update, :insert]
  action :grant
end
