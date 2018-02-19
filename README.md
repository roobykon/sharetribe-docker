1. add sharetribe.local >> /etc/hosts (or add your domain to docker-compose.yml instead sharetribe.local)
2. docker swarm init (enabled swarm mode to use 'docker stack' or adaptive docker-compose.yml for docker-compose command)
3. docker stack deploy --compose-file docker-compose.yml example
4. check mysql logs "docker service logs -f example_mysql" and wait before "mysqld: ready for connections"
5. restart app service "docker service update example_app"
6. open in browser http://sharetribe.local and finish setup marketplace
7. check email system working
8. check search system working
9. check memcache in logs
