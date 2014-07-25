default['railsstack']['unicorn']['workers'] = (node['cpu']['total'].to_i * 2)
default['railsstack']['unicorn']['backlog'] = 1024
default['railsstack']['unicorn']['after_fork'] = <<-EOS
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
EOS
