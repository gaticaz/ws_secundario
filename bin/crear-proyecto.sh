#!/usr/bin/env bash

cd `dirname $0`

if [ -f ../proyecto.ini ];
then
    echo "No se puede crear proyecto porque ya existe un 'proyecto.ini'"
    exit 1
fi

PROY=${TOBA_PROYECTO}
unset TOBA_PROYECTO
PATH_PROY=`realpath ..`
./toba proyecto crear -d ${PATH_PROY} -p ws_secundario -i desarrollo -a0
export TOBA_PROYECTO=${PROY}
