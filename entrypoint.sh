#!/usr/bin/env bash

set -e

if [ ! -f "/etc/ssh/sshd_config" ]; then
		mv /etc/ssh.dist/* "/etc/ssh/"

		for KEY_TYPE in "dsa" "rsa" "ecdsa" "ed25519"; do
				if [ -f "/etc/ssh/ssh_host_${KEY_TYPE}_key" ]; then
						rm "/etc/ssh/ssh_host_${KEY_TYPE}_key"
				fi
		done

		ssh-keygen -A

		echo >> "/etc/ssh/sshd_config"
		echo "Port 22" >> "/etc/ssh/sshd_config"
		echo "AddressFamily inet" >> "/etc/ssh/sshd_config"
		echo "ListenAddress 0.0.0.0" >> "/etc/ssh/sshd_config"
		echo "HostKey /etc/ssh/ssh_host_dsa_key" >> "/etc/ssh/sshd_config"
		echo "HostKey /etc/ssh/ssh_host_rsa_key" >> "/etc/ssh/sshd_config"
		echo "HostKey /etc/ssh/ssh_host_ecdsa_key" >> "/etc/ssh/sshd_config"
		echo "HostKey /etc/ssh/ssh_host_ed25519_key" >> "/etc/ssh/sshd_config"
		echo "PermitRootLogin yes" >> "/etc/ssh/sshd_config"
		echo "PasswordAuthentication no" >> "/etc/ssh/sshd_config"
		echo "PubkeyAuthentication yes" >> "/etc/ssh/sshd_config"
fi

echo "root:root" | chpasswd
usermod --shell /bin/bash root

if [ ! -f "/root/.ssh/authorized_keys" ]; then
		mkdir -p "/root/.ssh"
		touch "/root/.ssh/authorized_keys"
		chmod 0700 "/root/.ssh"
		chmod 0600 "/root/.ssh/authorized_keys"

		if [ "${SSH_PUBLIC_KEY}" != "" ]; then
				echo "${SSH_PUBLIC_KEY}" >> "/root/.ssh/authorized_keys"
		fi
fi

echo "" > "/etc/motd"

stop() {
    PID=$(cat "/var/run/sshd.pid")
    kill -SIGTERM "${PID}"
    wait "${PID}"
}

trap stop SIGINT SIGTERM
echo "> ${@}"
$@ &
PID="$!"
echo "${PID}" > "/var/run/sshd.pid"
wait "${PID}"
exit $?
