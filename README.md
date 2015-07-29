[![Circle CI](https://circleci.com/gh/rackspace-orchestration-templates/rails-app-multi/tree/master.png?style=shield)](https://circleci.com/gh/rackspace-orchestration-templates/rails-app-multi)
Description
===========

This template deploys a Ruby on Rails application from a git repo under
either unicorn & nginx, or mod_passenger & Apache 2 on multiple Linux servers
with [OpenStack Heat](https://wiki.openstack.org/wiki/Heat) on the [Rackspace
Cloud](http://www.rackspace.com/cloud/), with either a Postgres or MySQL back
end. This template uses the [chef-solo](http://docs.opscode.com/chef_solo.html)
provider to configure the servers.

Requirements
============
* A Heat provider that supports the Rackspace `OS::Heat::ChefSolo` plugin.
* An OpenStack username, password, and tenant id.
* [python-heatclient](https://github.com/openstack/python-heatclient)
`>= v0.2.8`:

```bash
pip install python-heatclient
```

We recommend installing the client within a [Python virtual
environment](http://www.virtualenv.org/).

Example Usage
=============
Here is an example of how to deploy this template using the
[python-heatclient](https://github.com/openstack/python-heatclient):

```
heat --os-username <OS-USERNAME> --os-password <OS-PASSWORD> --os-tenant-id \
  <TENANT-ID> --os-auth-url https://identity.api.rackspacecloud.com/v2.0/ \
  stack-create myrailsapp -f rails-app-multi.yaml \
  -P rails_rake_tasks=kandan:bootstrap -P rails_app_server_count=5 \
  -P rails_db_type=mysql -P rails_db_adapter=mysql2 \
  -P ruby_version=1.9.3-p547 -P app_git_url=https://github.com/myorg/myapp
```

* For UK customers, use `https://lon.identity.api.rackspacecloud.com/v2.0/` as
the `--os-auth-url`.

Optionally, set environment variables to avoid needing to provide these
values every time a call is made:

```
export OS_USERNAME=<USERNAME>
export OS_PASSWORD=<PASSWORD>
export OS_TENANT_ID=<TENANT-ID>
export OS_AUTH_URL=<AUTH-URL>
```

Parameters
==========
Parameters can be replaced with your own values when standing up a stack. Use
the `-P` flag to specify a custom parameter.

* `server_hostnames`: Hostname to give the Cloud Servers (Default:
  rails-%index%, note %index% is replaced with the resource index ID for each
  application node (0, 1, 2, ... n)))
* `image`: Operating system to use for all servers in this deployment.
  (Default: Ubuntu 12.04 LTS (Precise Pangolin))
* `flavor`: Server size to use for the application servers. (Default: 4 GB
  Performance)
* `db_flavor`: Server size to use for the database server. (Default: 4 GB
  Performance)
* `additional_packages`: Space delimited list of additional system packages to
  install. List any packages here required for your Gems to build. (Default:
  none)
* `domain`: Domain to be used with the rails app site, this will be used when
  setting up web services. (Default: rails.example.com)
* `ruby_version`: Version of Ruby to install (Default: 2.1.2)
* `rails_environment`: String to use as the rails environment name (Default:
  production)
* `rails_db_type`: Type of database to install, either `postgresql` or `mysql`.
  (Default: `mysql`)
* `rails_db_adapter`: Database adapter override. If supplied, this string will
  be used in the database.yml file to specify the adapter. By default
  `rails_db_type` will be used. You will need to use this for alternate
  adapters such as `mysql2`.
* `rails_rake_tasks`: a space-delimited list of additional rake tasks to run
  after `db:migrate` & `assets:precompile` (Default: none)
* `rails_app_server`: Application server to host your Rails application. unicorn
  implies nginx. Passenger implies apache.
  (Default: unicorn)
* `rails_app_server_count`: The number of Rails application servers to build.
  (Default: 2)
* `app_git_url`: Specifies a git URL from which to deploy the app (Default:
  none)
* `app_git_revision`: Git branch, tag, or commit hash of the application
  revision to
  deploy (Default: `master`)
* `app_git_deploy_key`: Key for deployment from a private git repo. (Default:
  none)
* `database_name`: Database name to use for the Rails application. (Default:
  railsapp_db)
* `database_username`: Username to use for the Rails application. (Default:
  railsapp_user)
* `child_template`: Location of the template to use for creating all Rails
  servers. (Default:
  https://raw.githubusercontent.com/rackspace-orchestration-templates/rails-app-multi/master/rails-app-server.yaml)
* `kitchen`: URL for the kitchen to clone with git. The Chef Solo run will copy
  all files in this repo into the kitchen for the chef run. (Default:
  https://github.com/rackspace-orchestration-templates/rails-app-multi)
* `chef_version`: Chef client version to install for the chef run.  (Default:
  11.12.8)
* `load_balancer_hostname`: Hostname to give the Cloud Load Balancer (Default:
  Rails-app-load-balancer)

Outputs
=======
Once a stack comes online, use `heat output-list` to see all available outputs.
Use `heat output-show <OUTPUT NAME>` to get the value fo a specific output.

* `private_key`: SSH private that can be used to login as root to the servers.
* `server_public_ips`: List of Rails application server IPs.
* `database_server_ip`: Database Server IP.
* `load_balancer_ip`: IP of the Load Balancer created with this deployment.
* `db_admin_password`: Database administrator password.
* `rails_app_url`: URL to access your Rails application via the load balancer

For multi-line values, the response will come in an escaped form. To get rid of
the escapes, use `echo -e '<STRING>' > file.txt`. For vim users, a substitution
can be done within a file using `%s/\\n/\r/g`.

Stack Details
=============
The application is deployed [Capistrano](http://capistranorb.com/)-style
in the home directory of the `rails` user in a directory based on the name of
the git repo.

Gems dependencies are installed by running a `bundle install --deployment` in
the application directory. This requires a Gemfile.lock in the application
repo.

Two rake tasks are run at deployment time: `rake db:migrate` followed by
`rake assets:precompile`

If you are using unicorn it must be declared in the application's Gemfile.

A unicorn.rb file is generated and placed in the application's config
directory along with a database.yml file configured to reference the
deployment's database server.

Contributing
============
There are substantial changes still happening within the [OpenStack
Heat](https://wiki.openstack.org/wiki/Heat) project. Template contribution
guidelines will be drafted in the near future.

License
=======
```
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
