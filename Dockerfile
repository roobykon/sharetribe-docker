FROM debian:stretch

ENV DEBIAN_FRONTEND noninteractive

ENV \
    RS_RUBY_VERSION="2.3.4" \
    RS_NODE_VERSION="7.8.0" \
    RS_USER="sharetribe" \
    RS_TMP_DIR="/tmp/sharetribe" \
    RAILS_ENV="development"

ENV \
    RS_BUILD_DEPS \
        patch \
        gawk \
        g++ \
        gcc \
        make \
        libc6-dev \
        patch \
        zlib1g-dev \
        libyaml-dev \
        libsqlite3-dev \
        sqlite3 \
        autoconf \
        libgmp-dev \
        libgdbm-dev \
        libncurses5-dev \
        automake \
        libtool \
        bison \
        pkg-config \
        libffi-dev \
        libgmp-dev \
        libreadline-dev \
        libssl1.0-dev \
        git \
        make \
        bzip2 \
        software-properties-common \
        dirmngr \
        gnupg2

ADD http://sphinxsearch.com/files/sphinx-2.2.11-1.rhel7.x86_64.rpm ${RS_TMP_DIR}/
COPY --chown=1000:1000 include ${RS_TMP_DIR}/

RUN apt-get update && \
    apt-get install \
        --no-install-recommends \
        --yes \
            ${RS_BUILD_DEPS} && \
    apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0xF1656F24C74CD1D8 && \
    add-apt-repository 'deb [arch=amd64] http://ftp.hosteurope.de/mirror/mariadb.org/repo/10.1/debian stretch main' && \
    apt-get update && \
    apt-get install \
        --no-install-recommends \
        --yes \
            supervisor \
            imagemagick \
            sphinxsearch \
            ssmtp \
            procps \
            mariadb-client \
            libmariadbclient-dev \
            libyaml-0-2 \
            curl

RUN useradd \
        --uid 1000 \
        --user-group \
        --shell /bin/bash \
        --create-home \
        --home-dir /home/${RS_USER} \
            sharetribe

RUN chown root:sharetribe /etc/ssmtp/ssmtp.conf && \
    chmod u=rwx,g=rwx,o= /etc/ssmtp/ssmtp.conf

USER ${RS_USER}:${RS_USER}
WORKDIR /home/${RS_USER}

RUN /bin/bash --login -c " \
        gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB && \
        curl --show-error --location https://get.rvm.io | bash -s stable && \
        source /home/${RS_USER}/.rvm/scripts/rvm && \
        rvm autolibs disable && \
        rvm install ${RS_RUBY_VERSION} && \
        rvm alias create default ${RS_RUBY_VERSION} && \
        rvm ${RS_RUBY_VERSION} do gem install bundler"

RUN /bin/bash --login -c " \
        curl --output - https://raw.githubusercontent.com/creationix/nvm/v0.33.6/install.sh | bash && \
        source /home/${RS_USER}/.nvm/nvm.sh && \
        nvm install ${RS_NODE_VERSION}"

RUN /bin/bash --login -c " \
        source /home/${RS_USER}/.rvm/scripts/rvm && \
        source /home/${RS_USER}/.nvm/nvm.sh && \
        git clone git://github.com/sharetribe/sharetribe.git www && \
        echo -e \"\ngem 'puma'\ngem 'daemons'\" >> www/Gemfile && \
        cd www && \
        rvm ${RS_RUBY_VERSION} do bin/bundle install && \
        nvm exec ${RS_NODE_VERSION} npm install && \
        cp ${RS_TMP_DIR}/puma.rb config/puma.rb && \
        mkdir -p tmp/pids tmp/sockets"

USER root
RUN apt-get remove \
        --purge \
        --auto-remove \
        --yes \
            ${RS_BUILD_DEPS} && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf ${RS_TMP_DIR}

COPY include/supervisord.conf /etc/supervisor/supervisord.conf
COPY include/docker-entrypoint.sh /docker-entrypoint.sh

USER ${RS_USER}:${RS_USER}
WORKDIR /home/${RS_USER}/www
EXPOSE 3000 9001

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["--server", "start"]
