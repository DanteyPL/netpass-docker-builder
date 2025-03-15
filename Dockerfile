FROM debian:12
LABEL version="0.2.4-alpha"
LABEL vendor1="DanteyPL"
ARG DEBIAN_FRONTEND=noninteractive
# Install required packages to install dkp
RUN apt-get update && apt-get install -y \
    wget \
    unzip
WORKDIR /build
# Installation of devkitpro-pacman; Script from https://devkitpro.org/wiki/devkitPro_pacman#:~:text=pacman%20instructions%20below.-,Debian%20and%20derivatives,devkitpro%2Dpacman%0A%20%20%20chmod%20%2Bx%20./install%2Ddevkitpro%2Dpacman%0A%20%20%20sudo%20./install%2Ddevkitpro%2Dpacman,-The%20apt%20repository
RUN wget https://apt.devkitpro.org/install-devkitpro-pacman
RUN chmod +x ./install-devkitpro-pacman
# Workaround for automation
RUN sed -i -e 's/apt-get install/apt-get install -y/' ./install-devkitpro-pacman
RUN eval ./install-devkitpro-pacman
RUN ln -s /proc/self/mounts /etc/mtab
# Installing required SDK for building
RUN dkp-pacman --noconfirm -S 3ds-dev 3ds-curl 3ds-libvorbisidec 3ds-opusfile 3ds-pkg-config
# Exporting required variables to .bashrc to have persistence after reboot of container
RUN echo "export DEVKITPRO=/opt/devkitpro" >> ~/.bashrc \
    && echo "export DEVKITARM=/opt/devkitpro/devkitARM" >> ~/.bashrc \
    && echo "export PATH=$PATH:/opt/devkitpro/devkitARM/bin" >> ~/.bashrc 
# Adding required enviroment variables
ENV DEVKITPRO /opt/devkitpro
ENV DEVKITARM /opt/devkitpro/devkitARM
# Install netpass packages dependencies
RUN apt-get update && apt-get --no-install-recommends install -y \
    ffmpeg \
    python3 \
    python3-pip
# Install Python requirements
RUN pip install PyYAML --break-system-packages
# Link pyton3 to python
RUN ln -s $(which python3) /usr/bin/python

RUN wget https://github.com/3DSGuy/Project_CTR/releases/download/makerom-v0.18.4/makerom-v0.18.4-ubuntu_x86_64.zip
RUN unzip makerom-v0.18.4-ubuntu_x86_64.zip -d $DEVKITPRO/tools/bin/
RUN chmod +x  $DEVKITPRO/tools/bin/makerom

RUN wget https://github.com/diasurgical/bannertool/releases/download/1.2.0/bannertool.zip
RUN unzip bannertool.zip -d ./
RUN cp ./linux-x86_64/bannertool $DEVKITPRO/tools/bin/

COPY ./docker-entrypoint.sh ./ 
# Clean package cache and list
RUN rm -rf /var/cache/apt/archives /var/lib/apt/lists/*
WORKDIR /build/source
ENTRYPOINT [ "/build/docker-entrypoint.sh" ]