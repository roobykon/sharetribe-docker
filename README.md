system requirements:
    docker-compose:
        docker version 1.12.0+
        docker-compose version 1.9.0+
    docker stack:
        docker version 17.09.0+

docker-compose:
  1. mkdir [your_project_folder]
  2. cd [your_project_folder]/prebuild
  3. git clone -b cloud-native git@gitlab.roobykon.com:anatoliy.zhuravlev/docker.git .
  4. docker build --tag sharetribe:prebuild .
  5. cd ../ && docker build --tag sharetribe .
  6. check all variables in .env
  7. docker-compose up -d
  8. waite ~90secret
  9. docker logs -f app
  10. open in browser http://localhost and finish setup marketplace
  11. docker exec app /docker-entrypoint.sh --help
  111. docker exec app /docker-entrypoint.sh config all
  12. check email system working
  13. check search system working
  14. check memcache in logs (optional)

docker stack: (THIS PART NOT TESTED)
  1. git clone -b cloud-native git@gitlab.roobykon.com:anatoliy.zhuravlev/docker.git
  2. docker swarm init (enabled swarm mode to use 'docker stack' or adaptive docker-compose.yml for docker-compose command)
  3. docker stack deploy --compose-file stack.yml example
  4. check mysql logs "docker service logs -f example_mysql" and wait before "mysqld: ready for connections"
  5. delete service with app "docker service rm example_app"
  6. docker stack deploy -c docker-compose.yml --prune example
  7. check logs for db_structure_load compleate "docker service logs -f example_app"
  8. open in browser http://localhost and finish setup marketplace
  9. check email system working
  10. check search system working
  11. check memcache in logs

ToDo:
  0. update and test stack.yml
  1. container with cron
  2. https with letsencrypt ssl certs
  3. container with backup system
  4. check why delayed_job cant exec sphinx commands when delayed_job and sphinx on separate hosts
