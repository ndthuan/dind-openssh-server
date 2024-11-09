FROM docker.io/docker:27.3.1-dind

RUN apk update && apk add --no-cache docker-cli rsync vim screen openssh curl sudo sed shadow

ADD entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]

VOLUME [ "/Users", "/home", "/server", "/var/lib/docker" ]

EXPOSE 22
