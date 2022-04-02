#!/bin/sh
SCRIPTPATH="$( cd "$(dirname "$0")" ; pwd -P )"
source "$SCRIPTPATH/.env"
if [ "$XFServerRoot" = "" ]; then
  export XFServerRoot=`php $SCRIPTPATH/print_config_var.php XFServerRoot`
fi
if [ "$XFServerPort" = "" ]; then
  export XFServerPort=`php $SCRIPTPATH/print_config_var.php XFServerPort`
fi

ACMD="$1"
ARGV="$@"

ERROR=0
if [ "x$ARGV" = "x" ] ; then 
    ARGV="-h"
fi

case $ACMD in
start|stop|restart|graceful|graceful-stop)
    sh $SCRIPTPATH/mysql.server.sh $ARGV
    if [ $? -eq 0 ]
    then
        #echo "Did $ARGV mysql server\n"
        :
    else
        echo "Failed to $ARGV mysql server."
        exit $?
    fi
    if [ $ACMD = "start" ]; then
        echo -n "Starting apache on port $XFServerPort..."
    elif [ $ACMD = "stop" ]; then
        echo -n "Stopping apache..."
    fi
    sh $SCRIPTPATH/apachectl.sh $ARGV
    if [ $? -eq 0 ]
    then
        #echo "Did $ARGV apache server\n"
        if [ $ACMD = "start" ]; then
            echo "SUCCESS!"
        elif [ $ACMD = "stop" ]; then
            echo "SUCCESS!"
        fi
    else
        echo "Failed to $ARGV apache server."
        exit $?
    fi
    ;;

*)

esac

exit $ERROR
