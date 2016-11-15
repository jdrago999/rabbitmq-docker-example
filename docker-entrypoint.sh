#!/bin/bash

set -e

export RABBITMQ_DEFAULT_USER
export RABBITMQ_DEFAULT_PASS
export RABBITMQ_DEFAULT_VHOST=${RABBITMQ_DEFAULT_VHOST:-"/"}

vars="
  RABBITMQ_DEFAULT_USER
  RABBITMQ_DEFAULT_PASS
"

for var in $vars
do
  # If the variable is already defined, then use it; otherwise, pull from AWS.
  eval val=\$$var
  if [ -z "$val" ]; then
    eval "export $var=$(credstash get $var)"
  else
    export $var
  fi
done

sudo service rabbitmq-server start
sleep 5
echo 'enabling...'
sudo rabbitmq-plugins enable rabbitmq_management

echo 'list users?'
sudo rabbitmqctl list_users

if sudo rabbitmqctl list_users | grep $RABBITMQ_DEFAULT_USER; then
  echo "user '$RABBITMQ_DEFAULT_USER' already exists"
else
  echo 'adding user.....'
  set
  sudo rabbitmqctl add_user $RABBITMQ_DEFAULT_USER $RABBITMQ_DEFAULT_PASS || echo 'weird...'
fi

echo 'list users (2)'
if sudo rabbitmqctl list_users | grep $RABBITMQ_DEFAULT_USER | grep -F "[administrator]"; then
  echo "user '$RABBITMQ_DEFAULT_USER' already tagged as 'administrator'"
else
  echo 'set user tags'
  sudo rabbitmqctl set_user_tags $RABBITMQ_DEFAULT_USER administrator
fi

sudo rabbitmqctl add_vhost $RABBITMQ_DEFAULT_VHOST || echo "vhost '$RABBITMQ_DEFAULT_VHOST' already exists"

echo 'list permissions?'
if sudo rabbitmqctl list_permissions -p $RABBITMQ_DEFAULT_VHOST | grep $RABBITMQ_DEFAULT_USER | grep "$RABBITMQ_DEFAULT_USER\\.\\*\\s+\\.\\*\\s+\\.\\*\$/"; then
  echo "user '$RABBITMQ_DEFAULT_USER' already has permissions '.* .* .*'"
else
  echo 'setting permissions'
  sudo rabbitmqctl set_permissions -p $RABBITMQ_DEFAULT_VHOST $RABBITMQ_DEFAULT_USER ".*" ".*" ".*"
fi

sudo service rabbitmq-server stop

echo 'finally'
exec "$@"
