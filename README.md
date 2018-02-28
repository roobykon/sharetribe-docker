#### About
 - this images builds from original sharetribe github repo
 - you can set custom user UID (default 1000) when building image. When container run sharetribe data load to "named volume" and bind to ./data and your user has full access to sharetribe data
 ```sh
 docker build --build-arg ${RS_UID} --tag sharetribe .
 ```
 - you can set your personal git repo when building images. Default valuens = master branch from official repo
 ```sh
 docker build --build-arg ${RS_GIT_BRANCH} --build-arg ${RS_GIT_REMOTE_URL} --tag sharetribe .
 ```
 - you can set RAILS_ENV when  building images. Default valuens = production
 ```sh
 docker build --build-arg ${RAILS_ENV} --build-arg ${NODE_ENV} --tag sharetribe .
 ```
 - for testing you may use builded images roobykon/sharetribe:prebuild and roobykon/sharetribe:latest
 - delayed_job and sphinx launched in one container - worker

#### system requirements:

##### docker-compose:
 - docker version 1.12.0+
 - docker-compose version 1.9.0+

##### docker stack:
 - docker version 17.09.0+

#### docker-compose:
```sh
git clone https://github.com/roobykon/sharetribe-docker.git [your_project_folder_name]
cd [your_project_folder_name]
# docker-compose.yml set vars: RS_UID RS_GIT_BRANCH RS_GIT_REMOTE_URL RAILS_ENV NODE_ENV
# .env check all vars
docker-compose up -d
# wait when image build finish ~5min
# check app logs if app container dont start
docker-compose logs --follow --timestamps --tail=100 app
# open in browser http://localhost and finish setup marketplace
docker-compose exec app /docker-entrypoint.sh --help
docker-compose exec app /docker-entrypoint.sh config all
# check email system working
# check search system working
# check memcache in app logs (optional)
# show stats
docker stats
```

#### docker stack: (THIS PART NOT TESTED)
```sh
git clone https://github.com/roobykon/sharetribe-docker.git
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
  - [x] add mailcatcher for development env
  - [x] set user UID in container via ARG
  - [ ] update and test stack.yml
  - [ ] container with cron
  - [x] https with letsencrypt ssl certs
  - [ ] container with backup system
  - [ ] check why delayed_job cant exec sphinx commands when delayed_job and sphinx on separate hosts
