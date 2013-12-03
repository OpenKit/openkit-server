#!/usr/bin/env bash

printf "This script assumes you have installed redis and mysql via homebrew!\n\n"

# Usage: 
# test_running <ps_param> <cmd_to_run>
function test_running {
  ps -ef | grep $1 | grep -v grep > /dev/null
  if [ $? -ne 0 ]
  then
    echo "Starting $1 in background."
    $2 > /dev/null 2>&1 &
  else
    echo "$1 already up."
  fi
}

test_running 'mysqld'         'mysql.server start'
test_running 'redis-server'   'redis-server /usr/local/etc/redis.conf'
