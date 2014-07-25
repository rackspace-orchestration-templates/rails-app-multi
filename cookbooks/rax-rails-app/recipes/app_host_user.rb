
user node['railsstack']['user'] do
  supports manage_home: true
  comment 'Rails user'
  home node['railsstack']['user_home']
  shell '/bin/bash'
  system true
end

group node['railsstack']['group'] do
  members node['railsstack']['user']
  append true
  action :modify
end

sudo node['railsstack']['user'] do
  nopasswd true
  user node['railsstack']['user']
end
