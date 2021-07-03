#!/bin/bash
username=$1
export DEBIAN_FRONTEND=noninteractive

is_in_group() {
  username="$1"
  groupname="$2"
  for group in $(id -Gn "$username") ; do
    if [ "$group" = "$groupname" ]; then
      return 0
    fi
  done
  # If it reaches this point, the user is not in the group.
  return 1
}

apt-get -qq update \
  && apt-get -qq install \
  apt-transport-https \
  ca-certificates \
  curl \
  gnupg \
  lsb-release \
  software-properties-common \
  < /dev/null > /dev/null \
  && curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --batch --yes --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg \
  && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list \
  && apt-get -qq update \
  && apt-get -qq install docker-ce=$(apt-cache madison docker-ce | grep 5.20.10 | head -1 | awk '{print $3}')  \
  docker-ce-cli=$(apt-cache madison docker-ce | grep 5.20.10 | head -1 | awk '{print $3}') \
  containerd.io=$(apt-cache madison containerd.io | grep 1.4.6 | head -1 | awk '{print $3}') \
  < /dev/null > /dev/null

export PATH="/usr/sbin:$PATH"
#TODO chec if user exist first, echo $? return coe 9
if ! [ $(getent group docker) ]; then
    groupadd docker
fi
if is_in_group $username docker; then
    usermod -aG docker $username
fi
systemctl enable docker.service
systemctl enable containerd.service
curl https://raw.githubusercontent.com/docker/docker/master/contrib/check-config.sh -o check-config.sh
#chmod +x ./check-config.sh
#./check-config.sh
#rm -f ./check-config.sh
exit 0
