#!/bin/sh

HOSTNAME=$(hostname)

echo "HOSTNAME is $HOSTNAME"

case "$HOSTNAME" in
	"Caritas")
		RAILS_ENV="production"
		;;
	"Purgatorio")
		RAILS_ENV="staging"
		;;
	*)
		RAILS_ENV="development"
		# echo "" >&2
		# exit 1
esac

echo "RAILS_ENV is $RAILS_ENV"

echo "unicorn_rails -D -c /var/www/apps/rails-stack-example/current/install/unicorn.rb -E $RAILS_ENV"
# bundle exec "unicorn_rails -D -c /var/www/apps/rails-stack-example/current/install/unicorn.rb -E $RAILS_ENV"
