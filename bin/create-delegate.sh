#!/bin/bash
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
source "$SCRIPTPATH/.env"
TABLES_DIR=$SCRIPTPATH/../app/tables
[ -d "$TABLES_DIR" ] || mkdir "$TABLES_DIR"

status=`bash $SCRIPTPATH/mysql.server.sh status`
if [[ $status == *"ERROR!"* ]]; then
    $SCRIPTPATH/mysql.server.sh start || (echo "Failed to start mysql" && exit 1)
    function finish() {
        $SCRIPTPATH/mysql.server.sh stop
    }
    trap finish EXIT
fi
bash $SCRIPTPATH/php.sh $SCRIPTPATH/inc/create-delegate.php "$@"