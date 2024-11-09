# dind-openssh-server

A Docker engine in a Docker container with SSH access.

Docker image: `ndthuan/dind-openssh-server`

Environment vars:
- USERNAME (default: dev)
- USER_ID (default: 1000)
- GROUP_ID (default: 1000)
- PUBLIC_KEY (optional, default: none): the content of the authorized public key(s).
- PUBLIC_KEY_URLS (optional, default: none): space-separated list of URLs that contain public keys. For example, https://github.com/ndthuan.keys

Note: either PUBLIC_KEY or PUBLIC_KEY_URLS, or both, must be set.

Volumes:
- /Users
- /home
- /server
- /var/lib/docker

# Run example

```shell
docker run --privileged -d \
    -v <path/volume>:/Users \
    -v <path/volume>:/home \
    -v <path/volume>:/server \
    -v <path/volume>:/var/lib/docker \
    -e PUBLIC_KEY_URLS="https://github.com/ndthuan.keys" \
    -p2222:22 ndthuan/dind-openssh-server:latest
```

# Compose example

```yaml
services:
  dm1:
    image: ndthuan/dind-openssh-server:latest
    container_name: dm1
    hostname: dm1
    privileged: true
    restart: always
    environment:
      - PUBLIC_KEY_URLS=https://github.com/ndthuan.keys
      - USERNAME=ndthuan
    volumes:
      - dm1-users:/Users
      - dm1-varlibdocker:/var/lib/docker
      - dm1-home:/home
      - dm1-server:/server
      - $HOME/.docker/config.json:/home/ndthuan/.docker/config.json
volumes:
  dm1-users:
  dm1-varlibdocker:
  dm1-home:
  dm1-server:
```
