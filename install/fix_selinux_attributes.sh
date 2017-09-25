#!/bin/sh
# Run this script as root.

# Version 1

# chcon -h -u system_u -t httpd_config_t /etc/nginx/nginx.conf
# chcon -h -u system_u -t systemd_unit_file_t /etc/systemd/system/rails-stack-example.service
# chcon -u system_u -t httpd_config_t /etc/nginx/nginx.conf
# chcon -u system_u -t systemd_unit_file_t /etc/systemd/system/rails-stack-example.service

# chcon -Rt httpd_sys_content_t /var/www/apps/rails-stack-example/current/public

# Version 2 : See https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Security-Enhanced_Linux/sect-Security-Enhanced_Linux-SELinux_Contexts_Labeling_Files-Persistent_Changes_semanage_fcontext.html

semanage fcontext -a -u system_u -t httpd_config_t /var/www/apps/rails-stack-example/current/install/nginx.conf
restorecon -v /var/www/apps/rails-stack-example/current/install/nginx.conf

semanage fcontext -a -u system_u -t httpd_config_t /etc/nginx/nginx.conf
restorecon -v /etc/nginx/nginx.conf

semanage fcontext -a -u system_u -t systemd_unit_file_t /var/www/apps/rails-stack-example/current/install/rails-stack-example.service
restorecon -v /var/www/apps/rails-stack-example/current/install/rails-stack-example.service

semanage fcontext -a -u system_u -t systemd_unit_file_t /etc/systemd/system/rails-stack-example.service
restorecon -v /etc/systemd/system/rails-stack-example.service

semanage fcontext -a -t httpd_sys_content_t "/var/www/apps/rails-stack-example/current/public(/.*)?"
restorecon -R -v /var/www/apps/rails-stack-example/current/public
