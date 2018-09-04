#!/bin/sh
for i in $NGINX_SERVER_NAME
do
    export NGINX_SERVER_NAME_AUX=${i}

    export RUN_CODE=$(echo ${i} | cut -d'.' -f 1)

    envsubst '$$PROJECT_ROOT $$NGINX_SERVER_NAME_AUX $$MAGE_MODE $$RUN_CODE $$RUN_TYPE' < /etc/nginx/sites/project.conf.template > /etc/nginx/sites/${NGINX_SERVER_NAME_AUX}.conf
done

nginx -g 'daemon off;'
