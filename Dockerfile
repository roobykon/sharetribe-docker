FROM ruby:2.3.4
SHELL ["/bin/bash", "--login", "-c"]

ENV RS_HOME_DIR_PREFIX="/home" \
    RS_USER="sharetribe" \
    RS_APP_ROOT="www" \
    RAILS_ENV="development" \
    ADD_SPHINX="sphinxsearch_2.2.11-release-1~jessie_amd64.deb"

ENV RS_BUILD_DEPS \
        software-properties-common

ADD http://sphinxsearch.com/files/${ADD_SPHINX} /tmp/${ADD_SPHINX}

RUN useradd \
        --uid 1000 \
        --user-group \
        --shell /bin/bash \
        --create-home \
        --home-dir ${RS_HOME_DIR_PREFIX}/${RS_USER} \
            ${RS_USER}

RUN apt-get update && \
        apt-get install \
        --no-install-recommends \
        --yes \
            ${RS_BUILD_DEPS} && \
    apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xcbcb082a1bb943db && \
    add-apt-repository 'deb [arch=amd64] http://ftp.hosteurope.de/mirror/mariadb.org/repo/10.1/debian jessie main' && \
    apt-get update && \
    apt-get install \
        --no-install-recommends \
        --yes \
            supervisor \
            imagemagick \
            ssmtp \
            mariadb-client \
            libmariadbclient-dev \
            libodbc1 \
            libpq5 \
            curl \
            git && \
    dpkg -i /tmp/${ADD_SPHINX} && \
    chown root:${RS_USER} /etc/ssmtp/ssmtp.conf && \
    chmod u=rw,g=rw,o= /etc/ssmtp/ssmtp.conf && \
    apt-get remove \
        --purge \
        --auto-remove \
        --yes \
            ${RS_BUILD_DEPS} && \
    apt-get clean && \
    rm \
        --recursive \
        --force \
            /var/lib/apt/lists/* \
            /tmp/${ADD_SPHINX}

COPY --chown=root:1000 include/supervisord.conf /etc/supervisor/supervisord.conf
COPY --chown=root:1000 include/docker-entrypoint.sh /docker-entrypoint.sh

USER ${RS_USER}:${RS_USER}
WORKDIR ${RS_HOME_DIR_PREFIX}/${RS_USER}

RUN git clone git://github.com/sharetribe/sharetribe.git ${RS_APP_ROOT} && \
    cd ${RS_APP_ROOT} && \
    echo -e "\ngem 'puma'" >> Gemfile && \
    bin/bundle install && \
    mkdir -p tmp/pids tmp/sockets node_modules

COPY --chown=1000:1000 include/puma.rb ${RS_HOME_DIR_PREFIX}/${RS_USER}/${RS_APP_ROOT}/config/puma.rb

WORKDIR ${RS_HOME_DIR_PREFIX}/${RS_USER}/${RS_APP_ROOT}
EXPOSE 3000 9001

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["--server", "start"]
