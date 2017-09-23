# README

This README would normally document whatever steps are necessary to get the application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

# This tutorial is from http://guides.rubyonrails.org/getting_started.html

# Link to the project: http://localhost:3000

###

Software Stack Setup Guide: PostgreSQL + nginx + rvm + Unicorn + Ruby on Rails on Fedora 26 LXDE + Systemd + SELinux

September 18-23, 2017

This "blog" example app is from http://guides.rubyonrails.org/getting_started.html

1) Install and configure Fedora 26 LXDE
	# dnf update
	# dnf install firefox git

	- Create a non-privileged user named "deployer":
	# useradd -p [password] deployer
		- To delete the user: # userdel -r deployer
		- Test the login process for the user via: $ ssh deployer@localhost (package openssh-server must be installed and running)

2) Globally install and configure rvm version ?
	- See https://rvm.io/rvm/install

	- Ensure that bash, curl, and gpg2 are installed
	# gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
	# \curl -sSL https://get.rvm.io | bash -s stable --ruby
	# source /usr/local/rvm/scripts/rvm
	# rvm list
	# which ruby
	# ruby -v
	# usermod -a -G rvm deployer

	X Not necessary: Ensure that Bash shells start with the "-l" (login) option
		- Put a shortcut to LXTerminal on the desktop. Then right-click on it and go to Properties -> Desktop Entry -> Command. Set tis value to: lxterminal -e "bash -il"

3) Install and configure PostgreSQL version 9.6.4-1.fc26.x86_64
	- See https://wiki.postgresql.org/wiki/First_steps
		- The default authentication mode is set to 'ident' which means a given Linux user xxx can only connect as the postgres user xxx. 

	# dnf install postgresql postgresql-server
	- Install the package needed to build the Ruby gem "pg" :
		- Fedora: # dnf install postgresql-devel
		- Ubuntu: # apt-get install libpq-dev
	
	X Not necessary when using 'ident' authentication: Edit the pg_hba.conf file:
		- In /etc/postgresql/9.5/main/pg_hba.conf (Windows: C:\PostgreSQL\data\pg_hba.conf), change:

		# IPv4 local connections:
		host    all             all             127.0.0.1/32            md5

		... to:

		# IPv4 local connections:
		host    all             all             127.0.0.1/32            trust

	# su - postgres
	$ initdb
	$ exit
	# systemctl status postgresql.service
	# systemctl (re)start postgresql.service
	- Ensure that the service starts at boot time: # systemctl enable postgresql.service
	# su - postgres
	$ psql

	postgres=# CREATE USER "deployer" WITH SUPERUSER PASSWORD '[password]';

		- See https://dba.stackexchange.com/questions/146087/postgresql-cannot-login-with-created-users
		! Do not confuse the PostgreSQL user named "deployer" with the Linux user named "deployer".

	postgres=# CREATE DATABASE "rails_stack_example_development" OWNER "deployer";
	postgres=# CREATE DATABASE "rails_stack_example_test" OWNER "deployer";
	postgres=# CREATE DATABASE "rails_stack_example_staging" OWNER "deployer";
	postgres=# CREATE DATABASE "rails_stack_example_production" OWNER "deployer";
	postgres=# \q

	- Test deployer's ability to access the databases:
	
	# su - deployer
	$ psql -d rails_stack_example_development

	deployer=# \q

	$ psql -d rails_stack_example_test

	deployer=# \q

	$ psql -d rails_stack_example_staging

	deployer=# \q

	$ psql -d rails_stack_example_production

	deployer=# \q

4) Install and configure Unicorn version ?
	# gem install unicorn

5) Install and configure the Ruby and Rails application (the "blog" app from the Rails "Getting Started page:  )
	# gem install bundler
	$ cd /var/www/apps/rails-stack-example
	Not necessary? : $ chgrp -R rvm .
	$ bundle
	$ rake db:migrate
	$ rails server
	- Browse to localhost:3000 and smoke-test the app.

	$ sudo -i
	# chown -R deployer:deployer /var/www/apps/rails-stack-example/
	# su - deployer
	$ unicorn -c /var/www/apps/rails-stack-example/install/unicorn.rb -E development (-D)
		- Or: $ bin/bundle exec "unicorn -c /var/www/apps/rails-stack-example/install/unicorn.rb -E development (-D)"

6) Install and configure nginx version ?
	# dnf install nginx
	- The Unicorn process launched by rails-stack-example.service will run as the user "deployer", who must be a member of the "nginx" group.
	# usermod -a -G nginx deployer
	# cd /etc/nginx
	# mv nginx.conf nginx_original.conf
	# ln -sf /var/www/apps/rails-stack-example/install/nginx.conf
	# ls -lZ nginx*
	# chcon -h -u system_u nginx.conf
	# chcon -u system_u -t httpd_config_t nginx.conf

	As deployer: $ chgrp -R nginx /var/www/apps/rails-stack-example/tmp/sockets/
		- The .sock file, must be readable and writable by user deployer and group nginx.
		- Setting the group sticky bit (chmod g+s) will ensure that any files created in this directory will have the same group as the directory itself (i.e. nginx).
		$ chmod g+s /var/www/apps/rails-stack-example/tmp/sockets/

	# systemctl restart nginx.service
	$ ps aux | grep nginx
	- Ensure that the service starts at boot time: # systemctl enable nginx.service

7) Create an SELinux policy module that will allow nginx to read from and write to the Unicorn Unix socket
	- To see the current status of SELinux: $ sestatus
	- Ensure that the app works with SELinux temporarily disabled
		- To temporarily disable SELinux: # setenforce 0
	- Test the app with SELinux enabled, so that SELinux's audit logs will include nginx's failed attempts to access the socket /var/www/apps/rails-stack-example/tmp/sockets/unicorn.sock
	- I had to repeat this process twice, because two different kinds of errors needed to be logged in audit.log before a sufficient policy could be created:
		- Attempt to GET http://localhost:8008
		# mkdir /home/deployer/SELinux[n]
		# cd /home/deployer/SELinux[n]
		# grep nginx /var/log/audit/audit.log
		# grep nginx /var/log/audit/audit.log | audit2allow -m nginx > nginx.te
		# checkmodule -M -m -o nginx.mod nginx.te
		# semodule_package -o nginx.pp -m nginx.mod
		# semodule -i nginx.pp
		X (Reboot.) -> A reboot is not required.

8) Configure systemd to start the "rails-stack-example" service automatically at boot time.
	- The services "nginx.service" and "postgresql.service" are found in /usr/lib/systemd/system
		- "# systemctl enable ..." creates symlinks in /etc/systemd/system/multi-user.target.wants/
	# cd /etc/systemd/system
	# ln -sf /var/www/apps/rails-stack-example/install/rails-stack-example.service
	# chcon -h -u system_u rails-stack-example.service
	# chcon -u system_u -t systemd_unit_file_t rails-stack-example.service
	# systemctl daemon-reload
	# systemctl enable rails-stack-example.service
	# systemctl status rails-stack-example.service
	# systemctl start rails-stack-example.service
	# systemctl status rails-stack-example.service
