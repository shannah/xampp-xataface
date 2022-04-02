#!/bin/bash
set -e
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"

if [ -d "$SCRIPTPATH/www" ]; then
  echo "www directory already exists.  Cancelling install"
  exit 1
fi

if [ ! -f "$SCRIPTPATH/.env" ]; then
  echo ".env file is missing.  Please copy the sample.env file to .env"
  exit 1
fi
source "$SCRIPTPATH/.env"
export XATAFACE_ENV_LOADED=1

COMPOSER=$(command -v composer)
if [ "$COMPOSER" = "" ]; then
  echo "composer not found.  Trying to install it..."
  "$SCRIPTPATH/bin/install-composer.sh"
  COMPOSER=$(command -v composer)
fi
if [ "$COMPOSER" = "" ]; then
  echo "composer not found after installing it.  Please make sure composer is in your PATH"
  exit 1
fi

# Now use composer to install the example app
"$COMPOSER" create-project "$COMPOSER_TEMPLATE_NAME" "www"

# Now install PHPMyAdmin
if [ ! -d "$SCRIPTPATH/lib/phpmyadmin" ]; then
  curl -L https://github.com/shannah/phpmyadmin/archive/master.zip > "$SCRIPTPATH/lib/phpmyadmin-master.zip"
  currdir=$(pwd)
  cd "$SCRIPTPATH"/lib
  unzip phpmyadmin-master.zip
  mv phpmyadmin-master phpmyadmin
  rm phpmyadmin-master.zip
  cd "$currdir"
fi


echo "Creating www/conf.db.ini.php"
cat << EOF > $SCRIPTPATH/www/conf.db.ini.php
;<?php exit;
[_database]
    host = "localhost"
    user = "$MYSQL_USER"
    password = "$MYSQL_PASSWORD"
    name = "$MYSQL_DATABASE"
    driver=mysqli
EOF

status=$(bash $SCRIPTPATH/bin/mysql.server.sh status || echo "ERROR!")
if [[ $status == *"ERROR!"* ]]; then
    echo "MySQL server isn't running yet.  Attempting to start it"
    echo "bash $SCRIPTPATH/bin/mysql.server.sh start"
    bash $SCRIPTPATH/bin/mysql.server.sh start || (echo "Failed to start mysql" && exit 1)
    function finish() {
        echo "bash $SCRIPTPATH/bin/mysql.server stop"
        bash $SCRIPTPATH/bin/mysql.server.sh stop
    }
    trap finish EXIT
else
  echo "Mysql Server is running"
fi

echo "create database $MYSQL_DATABASE"
mysql --socket="$SCRIPTPATH"/tmp/mysql.sock -u "$MYSQL_USER" -e "create database $MYSQL_DATABASE"



