#!/bin/bash
set -e

function mysql_connect_check() {
    mysql --host=${MYSQL_HOST} --user=${MYSQL_USER} --password=${MYSQL_PASSWORD} --skip-column-names --batch --execute="${1}"
}

function app_database_yml() {
    FILE_PATH="${RS_HOME_DIR_PREFIX}/${RS_USER}/${RS_APP_ROOT}/config/database.yml"
    echo "exec app_database_yml()"
    echo "${FILE_PATH}"
    if [[ -n ${MYSQL_DATABASE} ]] && [[ -n ${MYSQL_USER} ]] && [[ -n ${MYSQL_PASSWORD} ]] && [[ -n ${MYSQL_HOST} ]]; then
        FILE_PATH="${RS_HOME_DIR_PREFIX}/${RS_USER}/${RS_APP_ROOT}/config/database.yml"
        echo "${RAILS_ENV}:" > ${FILE_PATH}
        echo "    adapter: mysql2" >> ${FILE_PATH}
        echo "    database: ${MYSQL_DATABASE}" >> ${FILE_PATH}
        echo "    encoding: utf8" >> ${FILE_PATH}
        echo "    username: ${MYSQL_USER}" >> ${FILE_PATH}
        echo "    password: ${MYSQL_PASSWORD}" >> ${FILE_PATH}
        echo "    host: ${MYSQL_HOST}" >> ${FILE_PATH}
    fi
}

function app_config_yml() {
    FILE_PATH="${RS_HOME_DIR_PREFIX}/${RS_USER}/${RS_APP_ROOT}/config/config.yml"
    echo "exec app_config_yml()"
    echo "${FILE_PATH}"
        echo "${RAILS_ENV}:" > ${FILE_PATH}
        echo "  domain: 'lvh.me:80'" >> ${FILE_PATH}
        echo "  secret_key_base: ${RS_SECRET_KEY_BASE:-$(bin/bundle exec rake secret)}" >> ${FILE_PATH}
        echo "  sharetribe_mail_from_address: ${RS_AUTH_USER}@${RS_DOMAIN}" >> ${FILE_PATH}
}

function app_msmtp_conf() {
    FILE_PATH="${RS_HOME_DIR_PREFIX}/${RS_USER}/.msmtprc"
    echo "exec app_msmtp_conf()"
    echo "${FILE_PATH}"
    if [[ -n ${RS_DOMAIN} ]] && [[ -n ${RS_AUTH_USER} ]] && [[ -n ${RS_AUTH_PASS} ]]; then
        echo "# Set default values for all following accounts." > ${FILE_PATH}
        echo "defaults" >> ${FILE_PATH}
        echo "auth           on" >> ${FILE_PATH}
        echo "tls            off" >> ${FILE_PATH}
        echo "tls_trust_file /etc/ssl/certs/ca-certificates.crt" >> ${FILE_PATH}
        echo "logfile        ${RS_HOME_DIR_PREFIX}/${RS_USER}/.msmtp.log" >> ${FILE_PATH}
        echo "" >> ${FILE_PATH}
        echo "# smtp" >> ${FILE_PATH}
        echo "account        local" >> ${FILE_PATH}
        echo "host           smtp" >> ${FILE_PATH}
        echo "port           25" >> ${FILE_PATH}
        echo "from           ${RS_AUTH_USER}@${RS_DOMAIN}" >> ${FILE_PATH}
        echo "user           ${RS_AUTH_USER}@${RS_DOMAIN}" >> ${FILE_PATH}
        echo "password       ${RS_AUTH_PASS}" >> ${FILE_PATH}
        echo "" >> ${FILE_PATH}
        echo "# Set a default account" >> ${FILE_PATH}
        echo "account default : local" >> ${FILE_PATH}
    fi
    chmod u=rw,g=,o= ${FILE_PATH}
}

function db_structure_load() {
    set -x
    if [[ $(mysql_connect_check "SELECT COUNT(TABLE_NAME) FROM information_schema.TABLES WHERE TABLE_SCHEMA = \"${MYSQL_DATABASE}\";") = 0 ]]; then
        echo "exec db_structure_load()"
        bundle exec rake db:structure:load
    fi
    set +x
}

# if [[ -n ${TZDATA} ]]; then
#     cat /dev/null > /etc/locale.gen && \
#         echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
#         echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen && \
#         /usr/sbin/locale-gen && \
#     echo ${TZDATA} > /etc/timezone && \
#     dpkg-reconfigure --frontend noninteractive tzdata
# fi

case ${1} in
    app)
        app_database_yml
        app_config_yml
        app_msmtp_conf
        db_structure_load
        bundle exec passenger \
            start \
                --port "${PORT:-3000}" \
                --min-instances "${PASSENGER_MIN_INSTANCES:-1}" \
                --max-pool-size "${PASSENGER_MAX_POOL_SIZE:-1}" \
                --log-file "/dev/stdout" \
    ;;
    worker)
        app_msmtp_conf
        bundle exec rake ts:configure ts:index ts:start
        bundle exec rake jobs:work
    ;;
esac
