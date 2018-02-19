FROM sharetribe:onbuild

SHELL ["/bin/bash", "--login", "-c"]

LABEL maintainer="Roobykon Software - roobykon.com \
                  anatoliy.zhuravlev@roobykon.com \
                  contact@roobykon.com"

ENV RAILS_ENV="production" \
    NODE_ENV="production" \
    NPM_CONFIG_LOGLEVEL="error" \
    NPM_CONFIG_PRODUCTION="true" \
    RS_HOME_DIR_PREFIX="/opt" \
    RS_USER="app" \
    RS_APP_ROOT="www"

ARG RS_GIT_REMOTE_URL="https://github.com/sharetribe/sharetribe.git"
ARG RS_GIT_BRANCH="master"

RUN useradd \
        --uid 1000 \
        --user-group \
        --create-home \
        --home-dir ${RS_HOME_DIR_PREFIX}/${RS_USER} \
        --shell /bin/bash \
            ${RS_USER}

COPY include/docker-entrypoint.sh /docker-entrypoint.sh

USER ${RS_USER}:${RS_USER}

WORKDIR ${RS_HOME_DIR_PREFIX}/${RS_USER}

RUN git clone --branch ${RS_GIT_BRANCH} ${RS_GIT_REMOTE_URL} ${RS_APP_ROOT} && \
    cd ${RS_APP_ROOT} && \
    gem install bundler rake:11.3.0 && \
    bundle install --deployment --without test,development && \
    npm install && \
    script/prepare-assets.sh

WORKDIR ${RS_HOME_DIR_PREFIX}/${RS_USER}/${RS_APP_ROOT}
EXPOSE 3000
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["app"]
