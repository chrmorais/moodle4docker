#!/bin/bash

ROOT_FOLDER="/var/www/moodle"
MOODLE_FOLDER="$ROOT_FOLDER/html"
DATA_FOLDER="$ROOT_FOLDER/data"

set -e

if [ ! -f "$MOODLE_FOLDER/config.php" ]; then
  echo "=================================================="
  echo "Please wait. Preparing moodle installation."
  echo "=================================================="

  if [ ! -f "$ROOT_FOLDER/v$MOODLE_VERSION.tar.gz" ]; then
    echo "Moodle not found! Downloading from https://github.com/moodle/moodle/archive/v$MOODLE_VERSION.tar.gz"
    wget https://github.com/moodle/moodle/archive/v$MOODLE_VERSION.tar.gz -P $ROOT_FOLDER
  fi

  [ -d $MOODLE_FOLDER ] && rm -rf $MOODLE_FOLDER
  [ -d DATA_FOLDER ] && rm -rf DATA_FOLDER/*

  tar xfz $ROOT_FOLDER/v$MOODLE_VERSION.tar.gz -C /var/www/moodle && mv $ROOT_FOLDER/moodle-$MOODLE_VERSION $MOODLE_FOLDER

  mysql -h moodle_db -u root $MOODLE_DB_NAME && mysql -h moodle_db -u root -e "DROP DATABASE $MOODLE_DB_NAME" || echo "ok"

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
    chown -R www-data:www-data $MOODLE_FOLDER $DATA_FOLDER
    echo "INSTALLATION COMPLETE!"
    echo
    echo "url: http://$MOODLE_HOSTNAME"
    echo
    echo "admin user: $MOODLE_USER"
    echo "admin pass: $MOODLE_PASS"
    echo "=================================================="
  else
    echo "=================================================="
    echo " INSTALLATION ABORTED! MOODLE IS NOT INSTALLED. "
    echo "=================================================="
  fi
fi

# start all the services
/usr/bin/supervisord -n -c /etc/supervisord.conf


