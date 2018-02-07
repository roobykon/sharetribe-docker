FROM ruby:2.3.4
SHELL ["/bin/bash", "--login", "-c"]

LABEL maintainer="Roobykon Software - roobykon.com \
                  anatoliy.zhuravlev@roobykon.com \
                  contact@roobykon.com"

ENV RAILS_ENV="production" \
    NODE_ENV="production" \
    NODE_VERSION="7.8.0" \
    NPM_CONFIG_LOGLEVEL="error" \
    NPM_CONFIG_PRODUCTION="true" \
    RS_HOME_DIR_PREFIX="/opt" \
    RS_USER="app" \
    RS_APP_ROOT="www" \
    RS_SPHINX_URL="sphinxsearch_2.2.11-release-1~jessie_amd64.deb"

RUN useradd \
        --uid 1000 \
        --user-group \
        --create-home \
        --home-dir ${RS_HOME_DIR_PREFIX}/${RS_USER} \
        --shell /bin/bash \
            ${RS_USER}

ADD http://sphinxsearch.com/files/${RS_SPHINX_URL} /tmp/${RS_SPHINX_URL}
COPY --chown=root:1000 include/docker-entrypoint.sh /docker-entrypoint.sh

RUN apt-get update && \
    apt-get dist-upgrade \
        --no-install-recommends \
        --yes && \
    apt-get install \
        --no-install-recommends \
        --yes \
            imagemagick \
            mysql-client \
            libodbc1 \
            libpq5 \
            ssmtp \
            curl \
            git && \
    dpkg --install /tmp/${RS_SPHINX_URL} && \
    chown root:${RS_USER} /etc/ssmtp/ssmtp.conf && \
    chmod u=rw,g=rw,o= /etc/ssmtp/ssmtp.conf && \
    apt-get remove \
        --purge \
        --auto-remove \
        --yes && \
    apt-get clean && \
    rm \
        --recursive \
        --force \
            /var/lib/apt/lists/* \
            /tmp/${RS_SPHINX_URL}

RUN set -ex && \
    for key in \
        9554F04D7259F04124DE6B476D5A82AC7E37093B \
        94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
        FD3A5288F042B6850C66B31F09FE44734EB7990E \
        71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
        DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
        B9AE9905FFD7803F25714661B63B535A4C206CA9 \
        C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
        56730D5401028683275BD23C23EFEFE93C4CFFFE \
    ; do \
        gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key" || \
        gpg --keyserver pgp.mit.edu --recv-keys "$key" || \
        gpg --keyserver keyserver.pgp.com --recv-keys "$key" ; \
    done

RUN curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" && \
    curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" && \
    gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc && \
    grep " node-v$NODE_VERSION-linux-x64.tar.xz\$" SHASUMS256.txt | sha256sum -c - && \
    tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1 && \
    rm "node-v$NODE_VERSION-linux-x64.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt && \
    ln -s /usr/local/bin/node /usr/local/bin/nodejs

USER ${RS_USER}:${RS_USER}

RUN gem install bundler rake:11.3.0 && \
    mkdir --parents ${RS_HOME_DIR_PREFIX}/${RS_USER}/${RS_APP_ROOT}/${RS_APP_ROOT}/client/customloaders/customfileloader

WORKDIR ${RS_HOME_DIR_PREFIX}/${RS_USER}/${RS_APP_ROOT}

RUN curl --show-error --location --create-dirs --output Gemfile \
        https://raw.githubusercontent.com/sharetribe/sharetribe/master/Gemfile && \
    curl --show-error --location --create-dirs --output Gemfile.lock \
        https://raw.githubusercontent.com/sharetribe/sharetribe/master/Gemfile.lock && \
    curl --show-error --location --create-dirs --output package.json \
        https://raw.githubusercontent.com/sharetribe/sharetribe/master/package.json && \
    curl --show-error --location --create-dirs --output client/package.json \
        https://raw.githubusercontent.com/sharetribe/sharetribe/master/client/package.json && \
    curl --show-error --location --create-dirs --output client/customloaders/customfileloader/package.json \
        https://raw.githubusercontent.com/sharetribe/sharetribe/master/client/customloaders/customfileloader/package.json && \
    curl --show-error --location --create-dirs --output client/customloaders/customfileloader/index.js \
        https://raw.githubusercontent.com/sharetribe/sharetribe/master/client/customloaders/customfileloader/index.js

RUN bundle install --deployment --without test,development

RUN npm install

RUN rm --recursive --force *

EXPOSE 3000
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["web"]
