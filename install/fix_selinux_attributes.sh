#!/bin/sh
# Run this script as root.

chcon -h -u system_u -t httpd_config_t /etc/nginx/nginx.conf
chcon -h -u system_u -t systemd_unit_file_t /etc/systemd/system/rails-stack-example.service
chcon -u system_u -t httpd_config_t /etc/nginx/nginx.conf
chcon -u system_u -t systemd_unit_file_t /etc/systemd/system/rails-stack-example.service

# chcon -u system_u -t ?_t /var/www/apps/rails-stack-example/tmp/sockets/unicorn.sock
