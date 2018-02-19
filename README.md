1. add sharetribe.local >> /etc/hosts
2. docker swarm init (enabled swarm mode to use 'docker stack' or adaptive docker-compose.yml for docker-compose command)
3. docker stack deploy --compose-file docker-compose.yml example
4. open in browser http://sharetribe.local and finish setup marketplace
5. check email system working
6. check search system working
7. check memcache in logs
