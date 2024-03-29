FROM alpine:3.10.3

WORKDIR /

RUN apk update && \
	apk add shadow bash openssh rsync screen nano && \
	rm -rf /var/cache/apk/* && \
	mkdir -p /etc/ssh.dist && \
	mv /etc/ssh/* /etc/ssh.dist/

EXPOSE 22

VOLUME /etc/ssh

VOLUME /root

COPY ./entrypoint.sh ./entrypoint.sh

WORKDIR /root

ENTRYPOINT [ "/entrypoint.sh" ]

CMD [ "/usr/sbin/sshd", "-D", "-e", "-f", "/etc/ssh/sshd_config" ]