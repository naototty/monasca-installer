#!/usr/bin/env bash

# Copyright 2015 FUJITSU LIMITED
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except
# in compliance with the License. You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
# or implied. See the License for the specific language governing permissions and limitations under
# the License.
#


BASENAME=$(basename $0);

ARGS='';
TYPE='';
CONFIG='';

IS_ACTION=0
IS_INVENTORY=0; #add default inventory file
IS_CONFIG=0
IS_ERROR=0

DEFAULT_INVENTORY="./services-inventory.ini";
DEFAULT_CONFIG="services.yml";

help(){
    echo -e "\nusage: $BASENAME [OPTIONS]... [CONFIG] ACTION"
    if [ "$1" ]; then
        echo -e "\nTry '$BASENAME --help' for more options.";
    fi
}

help_full(){
    echo "Serivces supervisor."
    help;
    cat << EOF

Options

-h,  --help                  print this help
-i,  --inventory-file        set custom inventory file (default: $DEFAULT_INVENTORY)

[Config] - Custom config. (default: $DEFAULT_CONFIG)
Action  - Actions: (start|stop|status)


Examples

Run all services:
 $ $BASENAME start

Stop all services:
 $ $BASENAME stop

Show status all services:
 $ $BASENAME status

Custom config file:
 $ services.sh service.yml start

Custom inventory file:
 $ services.sh -i services-inventory.ini start

(file:services-inventory.ini)
[services-hosts]
mini-mon-online ansible_ssh_host=127.0.0.1 ansible_ssh_port=2200 ansible_ssh_private_key_file=~/.ssh/private_key
EOF
}

for var in "$@"
do
    case "$var" in
        "start")
            echo "Starting all services...";
            TYPE="start"
            IS_ACTION=1
            ARGS="$ARGS --e command=\"start\""
            ;;
        "stop")
            echo "Stopping all services";
            TYPE="stop"
            IS_ACTION=1
            ARGS="$ARGS --e command=\"stop\""
            ;;
        "status")
            echo "Services status"
            TYPE="status"
            IS_ACTION=1
            ARGS="$ARGS --e command=\"status\""
            ;;
        "-i" | --inventory-file=*)
            IS_INVENTORY=1;
            ARGS="$ARGS $var";
            ;;
        --help)
            help_full;
            exit;
            ;;
        *.yml)
            IS_CONFIG=1
            CONFIG=$var;
            ARGS="$ARGS $var";
            ;;
        *)
            ARGS="$ARGS $var";
    esac
done

if [ $IS_CONFIG == 0 ]; then
    if [ -f "$DEFAULT_CONFIG" ]; then
        ARGS="$ARGS $DEFAULT_CONFIG"
    else
        echo "Unable to find default config file: $DEFAULT_CONFIG";
        help 1;
        exit;
    fi
else
    if [ ! -f "$CONFIG" ]; then
        echo "Unable to find a config file: $CONFIG";
        help 1;
        exit;
    fi
fi

if [ $IS_ACTION == 0 ]; then
    echo "Unable to find action. Expected: start/stop/status";
    help 1;
    exit;
fi

CHANGED=0;
if [ $IS_INVENTORY == 0 ]; then
    if [ -f "$DEFAULT_INVENTORY" ]; then
        ARGS="$ARGS --inventory-file=$DEFAULT_INVENTORY";
    fi
fi

while IFS= read -r line
do
  if [ -z "$line" ]; then
      continue;
  fi

  if [ $IS_ERROR == 1 ]; then
      continue;
  fi

  if [[ $line =~ ^fatal:\ \[.+\]\ \=\>\ (.+)$ ]]; then
      echo "${BASH_REMATCH[1]}";
      IS_ERROR=1
  fi

  case "$TYPE" in
      "status")
          if [[ "$line" =~ '"msg":' ]]; then
            sline=`echo $line | awk -F': ' '{print $2}' | sed 's/[ "]//g'`
            read name status <<<$(IFS=";"; echo $sline)
            if [[ "$status" == "active" ]] ; then
                echo "Service '$name' running"
            else
                echo "Service '$name' stopped"
            fi
         fi
     ;;
     "start")
         if [[ $line =~ ^changed:\ \[.+\]\ \=\>\ \(item\=(.+)\)$ ]]; then
             CHANGED=1
             echo "Start service: ${BASH_REMATCH[1]}"
         fi
     ;;
     "stop")
         if [[ $line =~ ^changed:\ \[.+\]\ \=\>\ \(item\=(.+)\)$ ]]; then
             CHANGED=1
             echo "Stop service: ${BASH_REMATCH[1]}"
         fi
     ;;
  esac
done < <(stdbuf -oL ansible-playbook $ARGS)

if [ $IS_ERROR == 1 ]; then
    exit 1;
fi

if [ $CHANGED == 0 ]; then

    if [[ $TYPE == "start" ]]; then
       echo "There isn't any service to start";
    fi

    if [[ $TYPE == "stop" ]]; then
       echo "There isn't any service to stop.";
    fi
fi

