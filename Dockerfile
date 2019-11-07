FROM alpine:3.10.3

WORKDIR /

RUN apk update && \
	apk add shadow bash openssh rsync && \
	rm -rf /var/cache/apk/*

EXPOSE 22

COPY ./entrypoint.sh ./entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]

CMD [ "/usr/sbin/sshd", "-D", "-e", "-f", "/etc/ssh/sshd_config" ]