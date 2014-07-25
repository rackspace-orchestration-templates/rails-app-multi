# Encoding: utf-8

require_relative 'spec_helper'

describe port(80) do
  it { should be_listening }
end

describe group('rails') do
  it { should exist }
end

describe user('rails') do
  it { should exist }
  it { should belong_to_group 'rails' }
end

describe service('apache2') do
  it { should be_enabled }
  it { should be_running }
end

describe port(3306) do
  it { should be_listening }
end

describe service('mysqld') do
  it { should be_running }
end

describe command('curl http://localhost/users/sign_in') do
  it { should return_stdout /Username/ }
end
