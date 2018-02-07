FROM sharetribe:onbuild

LABEL maintainer="Roobykon Software - roobykon.com \
                  anatoliy.zhuravlev@roobykon.com \
                  contact@roobykon.com"

ARG RS_GIT_REMOTE_URL="https://github.com/sharetribe/sharetribe.git"
ARG RS_GIT_BRANCH="master"

RUN git clone --branch ${RS_GIT_BRANCH} ${RS_GIT_REMOTE_URL} .

RUN bundle install --deployment --without test,development

RUN npm install

RUN ./script/prepare-assets.sh
