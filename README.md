0. git clone -b cloud-native git@gitlab.roobykon.com:anatoliy.zhuravlev/docker.git
1. add sharetribe.local >> /etc/hosts (or add your domain to docker-compose.yml instead sharetribe.local)
2. docker swarm init (enabled swarm mode to use 'docker stack' or adaptive docker-compose.yml for docker-compose command)
3. docker stack deploy --compose-file docker-compose.yml example
4. check mysql logs "docker service logs -f example_mysql" and wait before "mysqld: ready for connections"
5. delete service with app "docker service rm example_app"
6. docker stack deploy -c docker-compose.yml --prune example
7. check logs for db_structure_load compleate "docker service logs -f example_app"
8. open in browser http://sharetribe.local and finish setup marketplace
9. check email system working
10. check search system working
11. check memcache in logs
