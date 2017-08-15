FROM ubuntu:16.04

# native platform development and build system functionality (about 400 MB installed)
RUN apt-get update && apt-get -y install \
    sudo \
    dialog \
    bsdmainutils \
    build-essential \
    curl \
    cppcheck \
    doxygen \
    libpcre3 \
    pcregrep \
    python3 \
    dialog \
    python-m2crypto \
    unzip \
    wget \
    chrpath \
    gawk \
    u-boot-tools \
    diffstat \
    pkg-config \
    cpio \
    libncurses5-dev \
    texinfo \
    git  \
    iputils-ping \
    dosfstools \
    mtools  \
    android-tools-fsutils

# Set the locale
RUN locale-gen en_US.UTF-8  
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8  

COPY init.sh /usr/bin/init.sh
RUN  chmod +x /usr/bin/init.sh

