FROM ruby:2.3.4

SHELL ["/bin/bash", "--login", "-c"]

LABEL maintainer="Roobykon Software - roobykon.com \
                  anatoliy.zhuravlev@roobykon.com \
                  contact@roobykon.com"

ENV NODE_VERSION="7.8.0" \
    NPM_CONFIG_LOGLEVEL="info" \
    RS_SPHINX_URL="sphinxsearch_2.2.11-release-1~jessie_amd64.deb"

ADD http://sphinxsearch.com/files/${RS_SPHINX_URL} /tmp/${RS_SPHINX_URL}

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
            msmtp-mta \
            curl \
            git && \
    dpkg --install /tmp/${RS_SPHINX_URL} && \
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
