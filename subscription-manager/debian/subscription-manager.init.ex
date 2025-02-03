#! /bin/sh

### BEGIN INIT INFO
# Provides:        subscription-manager
# Required-Start:    $remote_fs $network $syslog
# Required-Stop:    $remote_fs $network $syslog
# Default-Start:    2 3 4 5
# Default-Stop:        
# Short-Description:    subscription-manager
### END INIT INFO

PIDFILE=/var/run/subscription-manager/subscription-manager.pid
CONF=/etc/subscription-manager/subscription-manager.ini
USER=subscription-manager
GROUP=subscription-manager
BIN=/usr/bin/subscription-manager
OPTS="-d -c $CONF -p $PIDFILE"

. /lib/lsb/init-functions

if [ -f /etc/default/subscription-manager ]; then
    . /etc/default/subscription-manager
fi

start_subscription-manager(){
    log_daemon_msg "Starting subscription-manager" "subscription-manager" || true
    pidofproc -p $PIDFILE $BIN >/dev/null
    status="$?"
    if [ $status -eq 0 ]
    then
        log_end_msg 1 
        log_failure_msg \
        "subscription-manager already started"
        return 1
    fi
    mkdir -p `dirname $PIDFILE` -m 750
    chown $USER:$GROUP `dirname $PIDFILE`
    if start-stop-daemon -c $USER:$GROUP --start \
        --quiet --pidfile $PIDFILE \
        --oknodo --exec $BIN -- $OPTS
    then
        log_end_msg 0 || true
        return 0
    else
        log_end_msg 1 || true
        return 1
    fi

}

stop_subscription-manager(){
    log_daemon_msg "Stopping subscription-manager" "subscription-manager" || true
    if start-stop-daemon --stop --quiet \
        --pidfile $PIDFILE
    then
        log_end_msg 0 || true
        return 0
    else
        log_end_msg 1 || true
        return 1
    fi
}

wait_stop(){
    c=0
    while pidofproc -p $PIDFILE $BIN >/dev/null && [ $c -lt 10 ]
    do
        sleep 0.5
        c=$(( $c + 1 ))
    done
}

case "$1" in
  start)
    start_subscription-manager
    exit $?
    ;;
  stop)
    stop_subscription-manager
    exit $?
    ;;
  restart)
    stop_subscription-manager
    wait_stop
    start_subscription-manager
    exit $?
    ;;
  status)
    status_of_proc -p $PIDFILE $BIN "subscription-manager" \
        && exit 0 || exit $?
    ;;
  *)
    log_action_msg \
    "Usage: /etc/init.d/subscription-manager {start|stop|restart|status}" \
    || true
    exit 1
esac

exit 0
