FROM node:7.8
SHELL ["/bin/bash", "--login", "-c"]

ENV RS_HOME_DIR_PREFIX="/home" \
    RS_USER="node" \
    RS_APP_ROOT="www" \
    RAILS_ENV="development"

COPY --chown=root:1000 include/docker-entrypoint.sh /docker-entrypoint.sh

USER ${RS_USER}:${RS_USER}
WORKDIR ${RS_HOME_DIR_PREFIX}/${RS_USER}/${RS_APP_ROOT}

ENTRYPOINT ["/docker-entrypoint.sh"]
