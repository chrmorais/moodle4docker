#!/bin/bash

if [ ! -f /var/www/moodle/html/config.php ]; then
  # give some time for mysql to start.
  sleep 5
  echo
  echo "Please wait. Preparing moodle installation."
  echo
  sleep 10
  echo
  echo "Please wait. Installing moodle..."
  echo
  cd /var/www/moodle/html/admin/cli
  php install.php --wwwroot="http://localhost" \
    --dataroot="/var/www/moodle/data" \
    --dbhost="moodle_db" \
    --dbtype="mariadb" \
    --dbname="moodle" \
    --dbuser="root" \
    --fullname="Moodle Example" \
    --shortname="moodle" \
    --adminuser="admin" \
    --adminpass="admin123" \
    --agree-license \
    --non-interactive
  if [ $? -eq 0 ]; then
    echo "=================================================="
    chown -R www-data:www-data /var/www/moodle
    echo "INSTALLATION COMPLETE!"
    echo
    echo "url: http://localhost"
    echo
    echo "admin user: admin"
    echo "admin pass: admin123"
    echo "=================================================="
  else
    echo "=================================================="
    echo " INSTALLATION ABORTED! MOODLE IS NOT INSTALLED. "
    echo "=================================================="
  fi
fi

# start all the services
/usr/bin/supervisord -n -c /etc/supervisord.conf


