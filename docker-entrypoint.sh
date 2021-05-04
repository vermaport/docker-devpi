#!/bin/bash

function defaults {
    : ${DEVPISERVER_SERVERDIR="/data/server"}
    : ${DEVPICLIENT_CLIENTDIR="/data/client"}

    echo "DEVPISERVER_SERVERDIR is ${DEVPISERVER_SERVERDIR}"
    echo "DEVPICLIENT_CLIENTDIR is ${DEVPICLIENT_CLIENTDIR}"

    export DEVPISERVER_SERVERDIR DEVPICLIENT_CLIENTDIR
}

function initialise_devpi {
    echo "[RUN]: Initialise devpi-server"
    devpi-init
    devpi-server --restrict-modify root --start --host 127.0.0.1 --port 3141
    devpi-server --status
    devpi use http://localhost:3141
    devpi login root --password=''
    devpi user -m root password="${DEVPI_PASSWORD}"
    devpi index -y -c public pypi_whitelist='*'
    devpi-server --stop
    devpi-server --status
}

defaults

if [ "$1" = 'devpi' ]; then
    if [ ! -f  $DEVPI_SERVERDIR/.serverversion ]; then
        initialise_devpi
    fi

    echo "[RUN]: Launching devpi-server"
    exec devpi-server --restrict-modify root --host 0.0.0.0 --port 3141
fi

echo "[RUN]: Builtin command not provided [devpi]"
echo "[RUN]: $@"

exec "$@"
