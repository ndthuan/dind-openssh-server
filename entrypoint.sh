#!/bin/sh
set -eu

# if both PUBLIC_KEY and PUBLIC_KEY_URLS are not set, exit
if [ -z "${PUBLIC_KEY:-}" -a -z "${PUBLIC_KEY_URLS:-}" ]; then
    echo 'Please set PUBLIC_KEY and/or PUBLIC_KEY_URLS'
    exit 1
fi

user_id=${USER_ID:-1000}
username=${USERNAME:-dev}

if ! getent passwd ${username} > /dev/null; then
    adduser -D -u $user_id -g ${GROUP_ID:-1000} ${username}
    addgroup ${username} docker
    addgroup ${username} wheel
    passwd -d ${username}

    if ! grep -q '^%wheel ALL=(ALL) NOPASSWD: ALL' /etc/sudoers; then
        echo '%wheel ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
    fi
fi

actual_user_id=$(id -u ${username})
if [ "${user_id}" != "${actual_user_idd}" ]; then
    usermod -u ${user_id} ${username}
    echo "Changed user id of username ${username} to ${user_id}"
fi

for dir in /server/config /server/keys; do
    mkdir -p ${dir}
done


if [ ! -f /home/${username}/.ssh/authorized_keys ]; then
    mkdir -p /home/${username}/.ssh
    chmod 700 /home/${username}/.ssh
    touch /home/${username}/.ssh/authorized_keys
    chmod 600 /home/${username}/.ssh/authorized_keys
fi

if [ ! -s /home/${username}/.ssh/authorized_keys ]; then
    if [ -n "${PUBLIC_KEY:-}" ]; then
        echo $PUBLIC_KEY >> /home/${username}/.ssh/authorized_keys
    fi

    for url in ${PUBLIC_KEY_URLS:-}; do
        echo "Downloading public key from $url"
        # download the public key and append it to the authorized_keys file
        curl -sSL $url >> /home/${username}/.ssh/authorized_keys
    done
fi

chown -R ${username}:${username} /home/${username}/.ssh

if ! grep -q '^PasswordAuthentication no' /etc/ssh/sshd_config; then
    echo 'PasswordAuthentication no' >> /etc/ssh/sshd_config
fi

if ! grep -q '^PermitRootLogin no' /etc/ssh/sshd_config; then
    echo 'PermitRootLogin no' >> /etc/ssh/sshd_config
fi

if ! grep -q '^PubkeyAuthentication yes' /etc/ssh/sshd_config; then
    echo 'PubkeyAuthentication yes' >> /etc/ssh/sshd_config
fi

if ! grep -q 'Include /server/config' /etc/ssh/sshd_config; then
    echo 'Include /server/config/*.conf' >> /etc/ssh/sshd_config
fi

for key_type in rsa; do
    if ! grep -q "HostKey /server/keys/ssh_host_${key_type}_key" /etc/ssh/sshd_config; then
        echo "HostKey /server/keys/ssh_host_${key_type}_key" >> /etc/ssh/sshd_config
    fi

    if [ ! -f "/server/keys/ssh_host_${key_type}_key" ]; then
        # if key_type is rsa, we need to generate a 4096-bit key
        if [ "${key_type}" = 'rsa' ]; then
            ssh-keygen -q -N '' -t "${key_type}" -b 4096 -f "/server/keys/ssh_host_${key_type}_key"
        else
            ssh-keygen -q -N '' -t "${key_type}" -f "/server/keys/ssh_host_${key_type}_key"
        fi
    fi
done

# check if no line starts with 'SyslogFacility ' in /etc/ssh/sshd_config
if ! grep -q '^SyslogFacility ' /etc/ssh/sshd_config; then
    echo 'SyslogFacility AUTH' >> /etc/ssh/sshd_config
fi

# check if no line starts with 'LogLevel ' in /etc/ssh/sshd_config
if ! grep -q '^LogLevel ' /etc/ssh/sshd_config; then
    echo 'LogLevel INFO' >> /etc/ssh/sshd_config
fi

/usr/sbin/sshd -D &

/usr/local/bin/dockerd-entrypoint.sh "$@"
