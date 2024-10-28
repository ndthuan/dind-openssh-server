FROM lscr.io/linuxserver/openssh-server

RUN apk add --no-cache docker-cli docker-cli-compose rsync vim py3-pip
