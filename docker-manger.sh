#!/bin/sh
set -e

[ -z "$DOCKER_VERSION" ] && DOCKER_VERSION="17.06.2"

INSTALLER_PATH="/docker-releases"
DOWNLOAD_LOCATION="https://download.docker.com/linux/static/stable/x86_64"

remove_old_docker_version(){
	{
	    docker swarm leave --force
	    rm -f /usr/local/bin/docker*
	    rm -f /var/lib/docker.sock
    } &> /dev/null
}

download_docker_installer(){
	echo "Failed to locate docker installer locally. Checking online repository."
	curl --create-dirs -L --fail $DOWNLOAD_LOCATION/$1 -o $2
}


install_and_start_docker(){
    version_to_install="$1"
    version_to_install= [ -z "$1" ] && version_to_install=$DOCKER_VERSION
    INSTALLER_NAME="docker-$version_to_install.tgz"
    FULL_PATH="$INSTALLER_PATH/$INSTALLER_NAME"

	echo "Installing docker version $version_to_install"
	if [ ! -f "$FULL_PATH" ]; then
		download_docker_installer $INSTALLER_NAME $FULL_PATH
	fi
	
	if [ ! -f "$FULL_PATH" ]; then
		echo "Visit $DOWNLOAD_LOCATION to check available installers"
		exit 1;
	fi

	tar --extract --file $FULL_PATH --strip-components 1 --directory /usr/local/bin/
    nohup sh -c "$(which dind) dockerd --host=unix:///var/run/docker.sock --host=tcp://0.0.0.0:2375 --storage-driver=vfs" > /usr/local/bin/nohup.out 2>&1 &
    sleep 5
    chown go:go /var/run/docker.sock

	docker version && docker swarm init
}

show_help() {
 cat << EOF

Usage: dvm [-h | --help][command]
  Docker version manager

  --help | -h       Display this help.
  install           Installs the docker version specified or,
                    installs the docker version exported as "DOCKER_VERSION" environment variable.
  uninstall         Uninstalls the docker(if installed).

  example: dvm install 17.03.1
  example: dvm uninstall
EOF
}

case "${1}" in
    -h | --help | help)
    show_help;
    exit;;
    install)
        remove_old_docker_version && install_and_start_docker "${2}"
    exit;;
    uninstall)
        remove_old_docker_version
    exit;;
    *)
    show_help;
    exit;;
esac
