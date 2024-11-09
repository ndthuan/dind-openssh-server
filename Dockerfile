FROM docker.io/docker:dind

RUN apk update && apk add --no-cache docker-cli rsync vim screen openssh curl sudo sed shadow

ADD entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
VOLUME [ "/Users", "/home", "/server" ]
EXPOSE 22
