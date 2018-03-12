#!/bin/bash
set -e

export SPHINX_HOST="${SPHINX_HOST:-search}"
export MYSQL_HOST="${MYSQL_HOST:-mysql}"
export redis_host="${redis_host:-memcache}"
export redis_port="${redis_port:-6379}"
export redis_db="${redis_db:-1}"
export redis_expires_in="${redis_expires_in:-240}"
export RS_MAILCATCHER="${RS_MAILCATCHER:-0}"

function echo_info() {
    echo "${1}"
    echo "    >> ${2}"
}

function mysql_exec() {
    mysql --host=${MYSQL_HOST} --user=${MYSQL_USER} --password=${MYSQL_PASSWORD} --skip-column-names --batch --execute="${1}"
}

function app_database_yml() {
    FUNC_NAME="app_database_yml"
    FILE_PATH="${RS_HOME_DIR_PREFIX}/${RS_USER}/${RS_APP_ROOT}/config/database.yml"
    if [[ -n ${MYSQL_DATABASE} ]] && [[ -n ${MYSQL_USER} ]] && [[ -n ${MYSQL_PASSWORD} ]] && [[ -n ${MYSQL_HOST} ]]; then
        echo_info ${FUNC_NAME} ${FILE_PATH}
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
    FUNC_NAME="app_config_yml"
    FILE_PATH="${RS_HOME_DIR_PREFIX}/${RS_USER}/${RS_APP_ROOT}/config/config.yml"
    if [[ ! -f ${FILE_PATH} ]]; then
        echo_info ${FUNC_NAME} ${FILE_PATH}
        echo "${RAILS_ENV}:" > ${FILE_PATH}
        echo "  secret_key_base: \"${RS_SECRET_KEY_BASE:-$(bin/bundle exec rake secret)}\"" >> ${FILE_PATH}
        echo "  sharetribe_mail_from_address: \"${RS_AUTH_USER}@${RS_DOMAIN}\"" >> ${FILE_PATH}
    fi
}

function app_msmtp_conf() {
    FUNC_NAME="app_msmtp_conf"
    FILE_PATH="${RS_HOME_DIR_PREFIX}/${RS_USER}/.msmtprc"
    echo_info ${FUNC_NAME} ${FILE_PATH}
    if [[ $RS_MAILCATCHER = 1 ]]; then
        echo "# Set default values for all following accounts." > ${FILE_PATH}
        echo "defaults" >> ${FILE_PATH}
        echo "auth           off" >> ${FILE_PATH}
        echo "tls            off" >> ${FILE_PATH}
        echo "tls_trust_file /etc/ssl/certs/ca-certificates.crt" >> ${FILE_PATH}
        echo "logfile        ${RS_HOME_DIR_PREFIX}/${RS_USER}/.msmtp.log" >> ${FILE_PATH}
        echo "" >> ${FILE_PATH}
        echo "# smtp" >> ${FILE_PATH}
        echo "account        local" >> ${FILE_PATH}
        echo "host           sendmail" >> ${FILE_PATH}
        echo "port           1025" >> ${FILE_PATH}
        echo "from           ${RS_AUTH_USER}@${RS_DOMAIN}" >> ${FILE_PATH}
        echo "# user           ${RS_AUTH_USER}@${RS_DOMAIN}" >> ${FILE_PATH}
        echo "# password       ${RS_AUTH_PASS}" >> ${FILE_PATH}
        echo "" >> ${FILE_PATH}
        echo "# Set a default account" >> ${FILE_PATH}
        echo "account default : local" >> ${FILE_PATH}
    else
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
    FUNC_NAME="db_structure_load"
    FILE_PATH="mysql_exec"
    if [[ $(mysql_exec "SELECT COUNT(TABLE_NAME) FROM information_schema.TABLES WHERE TABLE_SCHEMA = \"${MYSQL_DATABASE}\";") = 0 ]]; then
        echo_info ${FUNC_NAME} ${FILE_PATH}
        bundle exec rake db:structure:load
    fi
}

function tmp_clean() {
    FUNC_NAME="tmp_clean"
    FILE_PATH="${RS_HOME_DIR_PREFIX}/${RS_USER}/${RS_APP_ROOT}/tmp/pids/server.pid"
    echo_info ${FUNC_NAME} ${FILE_PATH}
    if [[ -f ${FILE_PATH} ]]; then
        rm --recursive --force ${FILE_PATH}
    fi
}

# if [[ -n ${TZDATA} ]]; then
#     cat /dev/null > /etc/locale.gen && \
#         echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
#         echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen && \
#         /usr/sbin/locale-gen && \
#     echo ${TZDATA} > /etc/timezone && \
#     dpkg-reconfigure --frontend noninteractive tzdata
# fi

function help() {
    echo "usage: ${0} [OPTIONS]"
    echo "OPTIONS:"
    echo "-h | --help     - print help"
    echo ""
    echo "config domain   - set domain to db"
    echo "config payments - load payment table structure to db"
    echo "config all      - exec all config suboptions"
    echo ""
    echo "app deploy      - rake db:migrate"
    echo "app             - start app server"
    echo "worker          - start delayed_job and sphinxsearch"
}

case ${1}:${2} in
    config:domain)
        mysql_exec "UPDATE ${MYSQL_DATABASE}.communities SET domain = \"${RS_DOMAIN}\" WHERE id = '1';"
        mysql_exec "UPDATE ${MYSQL_DATABASE}.communities SET use_domain = '1' WHERE id = '1';"
    ;;
    config:payments)
        mysql_exec "INSERT INTO ${MYSQL_DATABASE}.payment_settings (id, active, community_id, payment_gateway, payment_process, commission_from_seller, minimum_price_cents, minimum_price_currency, minimum_transaction_fee_cents, minimum_transaction_fee_currency, confirmation_after_days, created_at, updated_at, api_client_id, api_private_key, api_publishable_key, api_verified, api_visible_private_key, api_country) VALUES (121240, 1, 1, 'paypal', 'preauthorize', NULL, NULL, NULL, NULL, NULL, 14, '2017-10-22 20:12:39', '2017-11-13 23:03:39', NULL, NULL, NULL, 0, NULL, NULL), (121241, 1, 1, 'stripe', 'preauthorize', NULL, NULL, NULL, NULL, NULL, 14, '2017-10-22 20:12:39', '2017-11-13 23:03:39', NULL, NULL, NULL, 0, NULL, NULL);"
        echo "  app_encryption_key: \"$(rake secret | cut --characters=1-64)\"" >> ${RS_HOME_DIR_PREFIX}/${RS_USER}/${RS_APP_ROOT}/config/config.yml
    ;;
    config:all)
        ${0} config domain
        ${0} config payments
    ;;
    app:deploy)
        bundle exec rake db:migrate
    ;;
    app:)
        tmp_clean
        app_database_yml
        app_config_yml
        app_msmtp_conf
        bundle install
        db_structure_load
        if [[ $(mysql_exec "SELECT COUNT(TABLE_NAME) FROM information_schema.TABLES WHERE TABLE_SCHEMA = \"${MYSQL_DATABASE}\";") -ne 0 ]]; then
            ${0} app deploy
        fi
        if [[ $RAILS_ENV = development ]] && [[ $NODE_ENV = development ]]; then
            bundle exec rake assets:clobber
            foreman start \
                --port "${PORT:-3000}" \
                --procfile Procfile.static
        else
            bundle exec rake assets:precompile
            bundle exec passenger \
                start \
                    --port "${PORT:-3000}" \
                    --min-instances "${PASSENGER_MIN_INSTANCES:-1}" \
                    --max-pool-size "${PASSENGER_MAX_POOL_SIZE:-1}" \
                    --log-file "/dev/stdout"
        fi
    ;;
    worker:)
        app_msmtp_conf
        bundle install
        if [[ $RS_MAILCATCHER = 1 ]]; then
            mailcatcher --ip 0.0.0.0 --no-quit
        fi
        bundle exec rake ts:configure ts:index ts:start
        bundle exec rake jobs:work
    ;;
    -h:|--help:) help ;;
    *) help ;;
esac
