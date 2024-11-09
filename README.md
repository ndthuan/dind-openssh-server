# dind-openssh-server

Image: `ndthuan/dind-openssh-server`

ENV vars:
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

