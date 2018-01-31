#!/bin/bash
set -e

function mysql_connect() {
  mysql --host=${MYSQL_HOST} --user=${MYSQL_USER} --password=${MYSQL_PASSWORD} --skip-column-names --batch --execute="${1}"
}

function sharetribe_database_yml() {
  echo "database.yml"
  if [[ -n ${MYSQL_DATABASE} ]] && [[ -n ${MYSQL_USER} ]] && [[ -n ${MYSQL_PASSWORD} ]] && [[ -n ${MYSQL_HOST} ]]; then
    FILE_PATH="/home/${RS_USER}/www/config/database.yml"
    echo "${RAILS_ENV}:" > ${FILE_PATH}
    echo "    adapter: mysql2" >> ${FILE_PATH}
    echo "    database: ${MYSQL_DATABASE}" >> ${FILE_PATH}
    echo "    encoding: utf8" >> ${FILE_PATH}
    echo "    username: ${MYSQL_USER}" >> ${FILE_PATH}
    echo "    password: ${MYSQL_PASSWORD}" >> ${FILE_PATH}
    echo "    host: ${MYSQL_HOST}" >> ${FILE_PATH}
  fi
}

function sharetribe_ssmtp_conf() {
  echo "ssmtp.conf"
  if [[ -n ${RS_DOMAIN} ]] && [[ -n ${RS_AUTH_USER} ]] && [[ -n ${RS_AUTH_PASS} ]]; then
    FILE_PATH="/etc/ssmtp/ssmtp.conf"
    echo "root=/dev/null" > ${FILE_PATH}
    echo "hostname=smtp.${RS_DOMAIN}" >> ${FILE_PATH}
    echo "rewriteDomain=${RS_DOMAIN}" >> ${FILE_PATH}
    echo "FromLineOverride=no" >> ${FILE_PATH}
    echo "mailhub=smtp.${RS_DOMAIN}" >> ${FILE_PATH}
    echo "AuthUser=${RS_AUTH_USER}" >> ${FILE_PATH}
    echo "AuthPass=${RS_AUTH_PASS}" >> ${FILE_PATH}
    echo "UseSTARTTLS=no" >> ${FILE_PATH}
    echo "UseTLS=no" >> ${FILE_PATH}
  fi
}

function db_structure_load() {
  echo "db_structure_load"
  if [[ $(mysql_connect "SELECT COUNT(TABLE_NAME) FROM information_schema.TABLES WHERE TABLE_SCHEMA = \"${MYSQL_DATABASE}\";") = 0 ]]; then
    bin/bundle exec rake db:structure:load
  fi
}

function sharetribe_config_yml() {
  echo "config.yml"
  FILE_PATH="/home/${RS_USER}/www/config/config.yml"
    echo "${RAILS_ENV}:" > ${FILE_PATH}
    echo "  domain: 'lvh.me:80'" >> ${FILE_PATH}
    echo "  secret_key_base: ${RS_SECRET_KEY_BASE:-$(bin/bundle exec rake secret)}" >> ${FILE_PATH}
    echo "  sharetribe_mail_from_address: ${RS_AUTH_USER}@${RS_DOMAIN}" >> ${FILE_PATH}
    echo "  feedback_mailer_recipients: manager@${RS_DOMAIN}"
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
  echo "usege: ${0} [OPTIONS]"
  echo "OPTIONS:"
  echo ""
  echo "--config"
  echo "  database     - set parameters to config/database.yml"
  echo "  config       - set parameters to config/config.yml"
  echo "  smtp         - set parameters ro /etc/ssmtp/ssmtp.conf"
  echo "  db_structure - bin/bundle exec rake db:structure:load"
  echo "  domain       - set domain to db"
  echo "  payments     - load payment table structure to db"
  echo "  all          - domain && payments"
  echo ""
  echo "--server"
  echo "  start        - set database.yml && set ssmtp.conf && start web server"
  echo ""
  echo "-h | --help    - print help"
  echo ""
}

case "$1:$2" in
  --config:database) sharetribe_database_yml ;;
  --config:config) sharetribe_config_yml ;;
  --config:ssmtp) sharetribe_ssmtp_conf ;;
  --config:db_structure) db_structure_load ;;
  --config:domain)
    mysql_connect "UPDATE ${MYSQL_DATABASE}.communities SET domain = \"${RS_DOMAIN}\" WHERE id = '1';"
    mysql_connect "UPDATE ${MYSQL_DATABASE}.communities SET use_domain = '1' WHERE id = '1';"
  ;;
  --config:payments)
    mysql_connect "INSERT INTO ${MYSQL_DATABASE}.payment_settings (id, active, community_id, payment_gateway, payment_process, commission_from_seller, minimum_price_cents, minimum_price_currency, minimum_transaction_fee_cents, minimum_transaction_fee_currency, confirmation_after_days, created_at, updated_at, api_client_id, api_private_key, api_publishable_key, api_verified, api_visible_private_key, api_country) VALUES (121240, 1, 1, 'paypal', 'preauthorize', NULL, NULL, NULL, NULL, NULL, 14, '2017-10-22 20:12:39', '2017-11-13 23:03:39', NULL, NULL, NULL, 0, NULL, NULL), (121241, 1, 1, 'stripe', 'preauthorize', NULL, NULL, NULL, NULL, NULL, 14, '2017-10-22 20:12:39', '2017-11-13 23:03:39', NULL, NULL, NULL, 0, NULL, NULL);"
  ;;
  --config:all)
    ${0} --config domain
    ${0} --config payments
  ;;
  --server:start)
    ${0} --config database
    ${0} --config config
    ${0} --config ssmtp
    ${0} --config db_structure
    /usr/bin/supervisord --nodaemon --configuration=/etc/supervisor/supervisord.conf
  ;;
  -h|--help) help ;;
  *) help ;;
esac
