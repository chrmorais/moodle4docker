#!/bin/bash

MOODLE_FOLDER="/var/www/moodle/html"
DATA_FOLDER="/var/www/moodle/data"

set -e

if [ ! -f "$MOODLE_FOLDER/config.php" ]; then
  echo "=================================================="
  echo "Please wait. Preparing moodle installation."
  echo "=================================================="

  if [ ! -f "/tmp/v$MOODLE_VERSION.tar.gz" ]; then
    echo "Moodle not found! Downloading from https://github.com/moodle/moodle/archive/v$MOODLE_VERSION.tar.gz"
    wget https://github.com/moodle/moodle/archive/v$MOODLE_VERSION.tar.gz -P /tmp
  fi

  [ -d $MOODLE_FOLDER ] && rm -rf $MOODLE_FOLDER

  tar xfz /tmp/v$MOODLE_VERSION.tar.gz -C /tmp
  mv /tmp/moodle-$MOODLE_VERSION $MOODLE_FOLDER

  [ -d "$DATA_FOLDER" ] || mkdir $DATA_FOLDER

  chown -R www-data:www-data $MOODLE_FOLDER $DATA_FOLDER

  echo "=================================================="
  echo "Installing moodle... this can take a while."
  echo "=================================================="
  cd /var/www/moodle/html/admin/cli
  php install.php --wwwroot="http://$MOODLE_HOSTNAME" \
    --dataroot="$DATA_FOLDER" \
    --dbhost="moodle_db" \
    --dbtype="mariadb" \
    --dbname="$MOODLE_DB_NAME" \
    --dbuser="root" \
    --fullname="Moodle LMS" \
    --shortname="Moodle" \
    --adminuser="$MOODLE_USER" \
    --adminpass="$MOODLE_PASS" \
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


