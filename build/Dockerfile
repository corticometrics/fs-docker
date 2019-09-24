# Dockerfile to build the dev branch of FreeSurfer
# Based on Ubuntu 16.04 LTS (Xenial Xerus)
FROM ubuntu:xenial

RUN apt-get update -qq \
  && apt-get install -y python3-pip python3-dev \
  && cd /usr/local/bin \
  && ln -s /usr/bin/python3 python \
  && pip3 install --upgrade pip

RUN apt-get install -y -q \
        automake1.11 \
        bc \
        binutils \
        build-essential \
        bzip2 \
        curl \
        git \
        gfortran \
        libbz2-dev \
        libfreetype6-dev \
        libgfortran-4.8-dev \
        libglu1-mesa-dev \
        libgomp1 \
        libjpeg62-dev \
        liblapack-dev \
        libssl-dev \
        libtool \
        libtool-bin \
        libx11-dev \
        libxaw7-dev \
        libxi-dev \
        libxml2-utils \
        libxmu-dev \
        libxmu-headers \
        libxmu6 \
        libxt-dev \
        libxt6 \
        perl \
        sudo \
        tar \
        tcsh \
        unzip \
        uuid-dev \
        vim-common \
        wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install cmake 3.12.3
RUN curl -sSL --retry 5 https://cmake.org/files/v3.12/cmake-3.12.3.tar.gz | tar -xz && \
    cd cmake-3.12.3 && ./configure && make && make install && cd - && \
    rm -rf cmake-3.12.3

RUN adduser --disabled-password --gecos '' docker && adduser docker sudo
USER docker

WORKDIR /fs
