FROM gocd/gocd-agent-alpine-3.5:v17.12.0

RUN apk add --no-cache ca-certificates && \
	set -ex && \
	apk add --no-cache bash curl tar btrfs-progs e2fsprogs e2fsprogs-extra iptables xfsprogs xz libressl openjdk8 git sudo && \
	set -x && \
	addgroup -S dockremap && \
	adduser -S -G dockremap dockremap && \
	echo 'dockremap:165536:65536' >> /etc/subuid && \
	echo 'dockremap:165536:65536' >> /etc/subgid  	

VOLUME /var/lib/docker
EXPOSE 2375

COPY docker-releases/ /docker-releases
COPY dind /usr/local/bin/
COPY docker-manger.sh /usr/local/bin/dvm

RUN chmod +x /usr/local/bin/dind && \
	chmod +x /usr/local/bin/dvm && \
	chown go:go /usr/local/bin/ && \
	echo "go ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers