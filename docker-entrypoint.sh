#!/bin/bash

set -e

export RABBITMQ_DEFAULT_USER
export RABBITMQ_DEFAULT_PASS
export RABBITMQ_DEFAULT_VHOST=${RABBITMQ_DEFAULT_VHOST:-"/"}

service rabbitmq-server start
sleep 5
echo 'enabling...'
rabbitmq-plugins enable rabbitmq_management

echo 'list users?'
rabbitmqctl list_users

if rabbitmqctl list_users | grep $RABBITMQ_DEFAULT_USER; then
  echo "user '$RABBITMQ_DEFAULT_USER' already exists"
else
  echo 'adding user.....'
  set
  rabbitmqctl add_user $RABBITMQ_DEFAULT_USER $RABBITMQ_DEFAULT_PASS || echo 'weird...'
fi

echo 'list users (2)'
if rabbitmqctl list_users | grep $RABBITMQ_DEFAULT_USER | grep -F "[administrator]"; then
  echo "user '$RABBITMQ_DEFAULT_USER' already tagged as 'administrator'"
else
  echo 'set user tags'
  rabbitmqctl set_user_tags $RABBITMQ_DEFAULT_USER administrator
fi

rabbitmqctl add_vhost $RABBITMQ_DEFAULT_VHOST || echo "vhost '$RABBITMQ_DEFAULT_VHOST' already exists"

echo 'list permissions?'
if rabbitmqctl list_permissions -p $RABBITMQ_DEFAULT_USER | grep $RABBITMQ_DEFAULT_USER | grep "$RABBITMQ_DEFAULT_USER\\.\\*\\s+\\.\\*\\s+\\.\\*\$/"; then
  echo "user '$RABBITMQ_DEFAULT_USER' already has permissions '.* .* .*'"
else
  echo 'setting permissions'
  rabbitmqctl set_permissions -p $RABBITMQ_DEFAULT_VHOST $RABBITMQ_DEFAULT_USER ".*" ".*" ".*"
fi

service rabbitmq-server stop

echo 'finally'
exec "$@"
