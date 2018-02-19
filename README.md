required:
  docker version 17.09.0+

1. git clone -b cloud-native git@gitlab.roobykon.com:anatoliy.zhuravlev/docker.git
2. add sharetribe.local >> /etc/hosts (or add your domain to docker-compose.yml instead sharetribe.local)
3. docker swarm init (enabled swarm mode to use 'docker stack' or adaptive docker-compose.yml for docker-compose command)
4. docker stack deploy --compose-file docker-compose.yml example
5. check mysql logs "docker service logs -f example_mysql" and wait before "mysqld: ready for connections"
6. delete service with app "docker service rm example_app"
7. docker stack deploy -c docker-compose.yml --prune example
8. check logs for db_structure_load compleate "docker service logs -f example_app"
9. open in browser http://sharetribe.local and finish setup marketplace
10. check email system working
11. check search system working
12. check memcache in logs
