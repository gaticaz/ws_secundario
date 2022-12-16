#!/usr/bin/env sh
set -e

: ${TOBA_PROYECTO_DIR:=/usr/local/app}
: ${TOBA_INSTALACION_DIR:=/usr/local/app/instalacion}
cd ${TOBA_PROYECTO_DIR}
test -x ${TOBA_PROYECTO_DIR}/entorno_toba.env && source ${TOBA_PROYECTO_DIR}/entorno_toba.env

REINSTALAR=0
FIX_PERMISSIONS=0
RECONFIGURE=0
RECONFIGURE_ALIAS=0
SERVE=0
CREARDB=0
DBEXISTENTE=0
INITIALIZEDB=0
UPDATEDB=0
START_WORKER_DOCS=0
START_JASPER=0
CHANGE_APACHE_USR=0
COMPILAR_PERFILES=0

break_loop=0

while [[ "$#" -gt 0 && ${break_loop} = 0 ]]; do
    key="$1"
    case ${key} in
        --fix-permissions)
        FIX_PERMISSIONS=1
        ;;
        --reinstalar)
        REINSTALAR=1
        ;;        
        --reconfigure)
        RECONFIGURE=1
        ;;
        --reconfigure-alias)
        RECONFIGURE_ALIAS=1
        ;;
        --compilar-perfiles)
        COMPILAR_PERFILES=1
        ;;        
        --create-db)
        CREARDB=1
        ;;
        --db-existente)
        DBEXISTENTE=1
        ;;
        --db-initialize)
        INITIALIZEDB=1
        ;;
        --db-migrate)
        UPDATEDB=1
        ;;
        --worker-docs)
        START_WORKER_DOCS=1
        ;;
        --start-jasper)
        START_JASPER=1
        ;;
        --change-apache-usr)
        CHANGE_APACHE_USR=1
        ;;        
        --serve)
        SERVE=1
        ;;
        --)
        break_loop=1
        ;;
        *)
        # unknown option
        ;;
    esac
    shift
done

FLAGS_INSTALADOR="--no-interaction --no-progress"
FLAGS_INSTALADOR_INSTALAR=""

if [[ ${CREARDB} = 1 ]]; then
    FLAGS_INSTALADOR_INSTALAR="${FLAGS_INSTALADOR_INSTALAR} --crear-db"
fi

if [ ${DBEXISTENTE} = 1 ]; then
    FLAGS_INSTALADOR_INSTALAR="${FLAGS_INSTALADOR_INSTALAR} --db-negocio-existente "
fi

if [[ ${CHANGE_APACHE_USR} = 1 ]]; then
    id -u op || adduser -D -u $APACHE_RUN_USER op
    sed -i "s/User apache/User op/" /etc/apache2/httpd.conf
fi

if [[ ${FIX_PERMISSIONS} = 1 ]]; then
    ./bin/instalador permisos:simple -U op -W apache --no-vendor ${FLAGS_INSTALADOR}
fi


if [[ ${CHANGE_APACHE_USR} = 1 ]]; then
    id -u op || adduser -D -u $APACHE_RUN_USER op
    sed -i "s/User apache/User op/" /etc/apache2/httpd.conf
fi

if [[ ${FIX_PERMISSIONS} = 1 ]]; then
    bin/instalador permisos:simple -U op -W apache --no-vendor ${FLAGS_INSTALADOR}
fi
if [ ${REINSTALAR} = 1 ]; then
    cd ${TOBA_PROYECTO_DIR}
    bin/instalador proyecto:desinstalar -n ${FLAGS_INSTALADOR}
    bin/instalador proyecto:instalar -n ${FLAGS_INSTALADOR_INSTALAR} ${FLAGS_INSTALADOR}
    bin/instalador instalacion:modo-mantenimiento --sin-mantenimiento -n ${FLAGS_INSTALADOR}
    bin/instalador permisos:simple -U op -W apache --no-vendor ${FLAGS_INSTALADOR}
fi

if [[ ${RECONFIGURE} = 1 ]]; then
    bin/instalador proyecto:reconfigurar db-negocio db-toba toba compilar-perfiles api-rest smtp --sin-mantenimiento --no-resguardar-config --no-validar-servicios ${FLAGS_INSTALADOR}
fi

if [[ ${INITIALIZEDB} = 1 ]]; then
    ./bin/instalador docker:db-inicializar ${FLAGS_INSTALADOR_INSTALAR} ${FLAGS_INSTALADOR}
fi

if [[ ${UPDATEDB} = 1 ]]; then
    bin/instalador docker:db-actualizar ${FLAGS_INSTALADOR_INSTALAR} ${FLAGS_INSTALADOR}
fi

if [[ ${COMPILAR_PERFILES} = 1 ]]; then
    ./bin/instalador proyecto:reconfigurar compilar-perfiles --sin-mantenimiento --no-resguardar-config --no-validar-servicios ${FLAGS_INSTALADOR}
fi

if [[ ${RECONFIGURE_ALIAS} = 1 ]]; then
    bin/instalador proyecto:reconfigurar url --sin-mantenimiento --no-resguardar-config --no-validar-servicios ${FLAGS_INSTALADOR}
fi

if [[ ${START_JASPER} = 1 ]]; then
    su -s /bin/bash apache -c "/usr/bin/java -Duser.language=es -Duser.country=AR -Djava.awt.headless=true -jar vendor/siu-toba/jasper/JavaBridge/WEB-INF/lib/JavaBridge.jar SERVLET_LOCAL:8081 3 &"
fi



eval "$@"

if [[ ${SERVE} = 1 ]]; then
    echo "sirviendo . . ."

    httpd -D FOREGROUND
fi
