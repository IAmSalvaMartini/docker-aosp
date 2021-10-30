#
# Minimum Docker image to build Android AOSP
#
FROM ubuntu:20.04

MAINTAINER IAmSalvaMartini <starraos@gmail.com>

# /bin/sh points to Dash by default, reconfigure to use bash until Android
# build becomes POSIX compliant
RUN echo "dash dash/sh boolean false" | debconf-set-selections && \
    dpkg-reconfigure -p critical dash

ENV TZ=Asia/Calcutta
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Keep the dependency list as short as reasonable
RUN apt-get update && apt-get install git tzdata apt-utils gnupg2 software-properties-common sudo -y
RUN git clone https://github.com/akhilnarang/scripts
RUN ls
RUN sed -i 's/sudo//g' scripts/setup/android_build_env.sh
RUN sed -i 's/systemctl restart udev/service udev restart/g' scripts/setup/android_build_env.sh
RUN sed -i 's/sudo//g' scripts/setup/make.sh
RUN bash scripts/setup/android_build_env.sh

ADD https://commondatastorage.googleapis.com/git-repo-downloads/repo /usr/local/bin/
RUN chmod 755 /usr/local/bin/*

# Install latest version of JDK
# See http://source.android.com/source/initializing.html#setting-up-a-linux-build-environment
WORKDIR /tmp

# All builds will be done by user aosp
COPY gitconfig /root/.gitconfig
COPY ssh_config /root/.ssh/config

# The persistent data will be in these two directories, everything else is
# considered to be ephemeral
VOLUME ["/tmp/ccache", "/aosp"]

# Work in the build directory, repo is expected to be init'd here
WORKDIR /aosp

COPY utils/docker_entrypoint.sh /root/docker_entrypoint.sh
ENTRYPOINT ["/root/docker_entrypoint.sh"]
