#!/bin/bash

case "$1" in
  "")
    echo -n "Please provide a parameter (start, stop, reload)."
    ;;
  start)
    echo -n "starting puma..."
    puma
    ;;
  stop)
    echo "stopping puma..."
    kill `cat tmp/pids/puma.pid`
    ;;
  reload)
    rm -rf log/development.log
    echo "reloading puma..."
    kill `cat tmp/pids/puma.pid`
    bundle exec puma
    ;;
esac

