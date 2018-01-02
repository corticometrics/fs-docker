# fs-docker

Dockerfiles for FreeSurfer (work in progress)

## fs-dev-xenial-build

Dockerfile to build the dev branch of FreeSurfer based on Ubuntu 16.04.3 LTS (Xenial Xerus)

### Setup
```
mkdir ./fs-xenial
cd ./fs-xenial
mkdir -p ./bin
wget ftp://surfer.nmr.mgh.harvard.edu/pub/dist/fs_supportlibs/prebuilt/centos6_x86_64/centos6-x86_64-packages.tar.gz
tar zxvf ./centos6-x86_64-packages.tar.gz
git clone https://github.com/freesurfer/freesurfer.git ./freesurfer
cd ./freesurfer
git fetch
git checkout dev
git merge origin/dev
cd ..
```

### Build/Tag Container
```
git clone git@github.com:corticometrics/fs-docker.git
cd ./fs-docker
docker build -f ./dockerfile.fs-dev-xenial-build -t fs-dev-xenial-build:latest .
cd ..
```

### Go Interacive
```
cd ..
docker run -it --rm -v ${PWD}/fs:/fs -w /fs -u ${UID}:${GID} fs-dev-xenial-build:latest /bin/bash
```

Compile freesurfer dev branch inside container:
```
cd ./centos6-x86_64-packages
./setup.sh
cd ../freesurfer
./setup_configure
./configure --prefix=/fs/bin --with-pkgs-dir=/fs/centos6-x86_64-packages --disable-GUI-build --disable-Werror
make -j4
```
