# fs-docker

Dockerfiles for FreeSurfer (work in progress)

## fs-dev-xenial-build

Dockerfile to build the dev branch of FreeSurfer based on Ubuntu 16.04.3 LTS (Xenial Xerus)

### Pre-reqs
- Install docker
- Install git
- Install git-annex

### Setup
We want to make a directory structure that looks like:
```
├── fs-xenial
    ├── bin
    ├── centos6-x86_64-packages
    ├── freesurfer
    └── fs-docker
```

Where:
  - `./fs-xenial/bin/` is where the compiled freesurfer binaries will be installed with `make install`
  - `./fs-xenial/centos6-x86_64-packages/` is where the pre-compiled libraries go
  - `./fs-xenial/freesurfer` is the [freesurfer repo](https://github.com/freesurfer/freesurfer)
  - `./fs-xenial/fs-docker` is this repo.

```
mkdir ~/fs-xenial/bin
cd ~/fs-xenial
wget ftp://surfer.nmr.mgh.harvard.edu/pub/dist/fs_supportlibs/prebuilt/centos6_x86_64/centos6-x86_64-packages.tar.gz
tar zxvf ./centos6-x86_64-packages.tar.gz
git clone https://github.com/freesurfer/freesurfer.git ./freesurfer
cd ./freesurfer
git fetch
git checkout dev
git merge origin/dev
```

You can compile freesurfer now, but if you want to install/run it, some additional files are needed:
```
git remote add datasrc https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/repo/annex.git
git fetch datasrc
git annex enableremote datasrc
git annex get --metadata fstags=makecheck . && git annex get --metadata fstags=makeinstall .
```

### Build/Tag Container
```
cd ~/fs-xenial
git clone git@github.com:corticometrics/fs-docker.git
cd ./fs-docker
docker build -f ./dockerfile.fs-dev-xenial-build -t fs-dev-xenial-build:latest .
```

### Go Interacive

Mount the `fs-xenial` directory to `/fs` inside the container; make `/fs` the working directory and preserve UID/GID
```
cd ~
docker run -it --rm -v ${PWD}/fs-xenial:/fs -w /fs -u ${UID}:${GID} fs-dev-xenial-build:latest /bin/bash
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

If you've run `git annex get --metadata fstags=makeinstall .` above, you should be able to:
```
make install
```
Now, type `exit` to exit the container.  You should now have a full freesurfer install dir at `~/fs-xenial/bin`
