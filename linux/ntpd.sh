#!/bin/sh
#
# Based on a version by Esther Epstein <esther@darwin.bu.edu> of December 20,
# 2000, for delbrueck.bu.edu.
#
#    Modification history:
#
# modified into a Linux version.  -- rgr, 31-Dec-00.
# make start & stop cleaner.  -- rgr, 5-Apr-01.
#

# Source function library.
. /etc/rc.d/init.d/functions

# Source networking configuration.
if [ ! -f /etc/sysconfig/network ]; then
    exit 0
fi

. /etc/sysconfig/network

case "$1" in
  'start')
      # Check that networking is up.
      [ ${NETWORKING} = "no" ] && exit 0
      # Only start if there is a config file and a binary.
      if [ ! -r /etc/ntp.conf ]; then
	  exit 0
      fi
      if [ ! -x /usr/local/bin/ntpd ]; then
          echo "$0:  No /usr/local/bin/ntpd available; not starting."
	  exit 0
      fi
      # See if already running.
      if [ "`pidofproc ntpd`" != "" ]; then
          echo $0: Already running \(PID `pidofproc ntpd`\).
	  echo $0: Use \"$0 restart\" if you really want to kill the old one.
	  exit 0
      fi
      # check for servers
      ARGS=`perl -ane 'print "$F[1] " if $F[0] eq "server";' /etc/ntp.conf`
      if [ ! -z "$ARGS" ]; then
	  # wait until date is close before starting ntpd
	  /usr/local/bin/ntpdate $ARGS
	  sleep 2
	  /usr/local/bin/ntpd
      else
	  /usr/local/bin/ntpd
      fi
      ;;

  'stop')
      # [this doesn't make sense . . .  -- rgr, 5-Apr-01.]
      # killproc ntpdate
      if [ "`pidofproc ntpd`" = "" ]; then
          echo $0: NTP server is not running.
      else
	  echo -n "Stopping NTP server:"
	  killproc ntpd
	  echo
      fi
      ;;

  'restart')
      $0 stop
      $0 start
      ;;

  'status')
      status ntpd
      ;;

  *)
      echo "Usage: $0 {start|stop|status|restart}"
      ;;
esac
