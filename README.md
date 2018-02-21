#### About
 - this images builds from original sharetribe github repo
 - you can set your personal git repo when building images
  - docker build --build-arg ${RAILS_ENV} --build-arg ${NODE_ENV} --build-arg ${RS_GIT_BRANCH} --build-arg ${RS_GIT_REMOTE_URL} --tag sharetribe .

#### system requirements:

##### docker-compose:
 - docker version 1.12.0+
 - docker-compose version 1.9.0+

##### docker stack:
 - docker version 17.09.0+

#### docker-compose:
```sh
mkdir [your_project_folder]
cd [your_project_folder]
git clone git@gitlab.roobykon.com:anatoliy.zhuravlev/docker.git .
cd prebuild
docker build --tag sharetribe:prebuild .
cd ../ && docker build --tag sharetribe .
# check all variables in .env
docker-compose up -d
# waite ~90sec
docker logs -f app
# open in browser http://localhost and finish setup marketplace
docker exec app /docker-entrypoint.sh --help
docker exec app /docker-entrypoint.sh config all
# check email system working
# check search system working
# check memcache in logs (optional)
```

#### docker stack: (THIS PART NOT TESTED)
```sh
git clone -b cloud-native git@gitlab.roobykon.com:anatoliy.zhuravlev/docker.git
docker swarm init (enabled swarm mode to use 'docker stack' or adaptive docker-compose.yml for docker-compose command)
docker stack deploy --compose-file stack.yml example
check mysql logs "docker service logs -f example_mysql" and wait before "mysqld: ready for connections"
delete service with app "docker service rm example_app"
docker stack deploy -c docker-compose.yml --prune example
check logs for db_structure_load compleate "docker service logs -f example_app"
open in browser http://localhost and finish setup marketplace
check email system working
check search system working
check memcache in logs
```

#### ToDo:
  - update and test stack.yml
  - container with cron
  - https with letsencrypt ssl certs
  - container with backup system
  - check why delayed_job cant exec sphinx commands when delayed_job and sphinx on separate hosts
