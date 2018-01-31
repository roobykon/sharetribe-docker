#!/bin/bash
set -e

cd ${RS_HOME_DIR_PREFIX}/${RS_USER}/${RS_APP_ROOT} && npm install
cd ${RS_HOME_DIR_PREFIX}/${RS_USER}/${RS_APP_ROOT}/client && npm run build:client
cd ${RS_HOME_DIR_PREFIX}/${RS_USER}/${RS_APP_ROOT}/client && npm run build:server

exit 0
