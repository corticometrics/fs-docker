# fs-docker

Dockerfiles for FreeSurfer (work in progress)

## The `fs-dev-xenial-build` container

The `fs-dev-xenial-build` container is used to build the dev branch of FreeSurfer and is based on Ubuntu 16.04.3 LTS (Xenial Xerus).  It is build from the file `dockerfile.fs-dev-xenial-build`

### Pre-reqs
- Install docker
- Install git
- Install git-annex

### Setup
Outside the container, we want to make a directory structure that looks like:
```
├── fs-xenial
    ├── bin
    ├── freesurfer
    └── fs-docker
```

Where:
  - `./fs-xenial/bin/` is where the compiled freesurfer binaries will be installed with `make install`
  - `./fs-xenial/freesurfer` is the [freesurfer repo](https://github.com/freesurfer/freesurfer)
  - `./fs-xenial/fs-docker` is this repo.

The `fs-xenial` directory will get mounted to `/fs` inside the container when it is executed.

```
mkdir -p ~/fs-xenial/bin
cd ~/fs-xenial
git clone https://github.com/freesurfer/freesurfer.git ./freesurfer
cd ./freesurfer
git checkout dev
```

You can compile freesurfer now, but if you want to install/run it, some additional files are needed:
```
git remote add datasrc https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/repo/annex.git
git fetch datasrc
git annex enableremote datasrc
git annex get --metadata fstags=makecheck . && git annex get --metadata fstags=makeinstall .
```

If the annex tags haven't been updated, you might need to run
```
git annex get .
```

### Build/Tag Containers
```
make fs-dev-xenial-build
```

### Compile freesurfer dev branch inside container:

### Go interactive 
Mount the `fs-xenial` directory to `/fs` inside the container; make `/fs` the working directory and preserve UID/GID
```
cd ~
docker run -it --rm -v ${PWD}/fs-xenial:/fs -w /fs -u ${UID}:${GID} corticometrics/fs-dev-xenial-build:latest /bin/bash
```

### Compile freesurfer
```
cd ./freesurfer
./setup_configure
cd ./packages
make build-vxl
cd ..
./configure --prefix=/fs/bin --enable-small-build-dist --disable-g
make -j4
```

### Install
If you've run `git annex get --metadata fstags=makeinstall .` above, you should be able to:
```
make install
```
This should install FreeSurfer to `~/fs-xenial/bin`

Now, type `exit` to exit the container.  You should now have a full freesurfer install dir at `~/fs-xenial/bin`

## The `fs-dev-xenial-recon-all` container

The `fs-dev-xenial-recon-all` container is used to build the dev branch of FreeSurfer and is based on Ubuntu 16.04.3 LTS (Xenial Xerus).  It is build from the file `dockerfile.fs-dev-xenial-recon-all`

### Pre-reqs
- Install docker
- Obtain FreeSurfer binaries (either by following the steps above to compile or [download](https://surfer.nmr.mgh.harvard.edu/fswiki/DownloadAndInstall))
- Obtain FreeSurfer subject data to recon
- Obtain FreeSurfer license (from [here](https://surfer.nmr.mgh.harvard.edu/registration.html)) 

### Setup

#### Build/Tag Container
```
cd ./fs-docker
docker build -f ./dockerfile.fs-dev-xenial-recon-all -t fs-dev-xenial-recon-all:latest .
```

#### Get `FS_KEY` value

The [entrypoint script](entrypoint.fs-dev-xenial-recon-all.bash) for this container looks for the environment variable `FS_KEY` and, if present, will base64-decode the string and store the contents in the file $FREESURFER_HOME/license.txt.  Most of FreeSurfer will not work without this license file.  

Obtaining a license file is free and can be applied for [here](https://surfer.nmr.mgh.harvard.edu/registration.html).  Once you have the license file, run `cat ./license.txt |base64 -w 0 && echo` to get the string that you should set the `FS_KEY` environment variable to.

### Recon a subject

The `fs-dev-xenial-recon-all` container expects: 
  - 2 volumes to be mounted.
    - The FreeSurfer install directory (`$FREESURFER_HOME`) should be mounted to `/freesurfer-bin` 
    - The FreeSurfer subjects directory (`$SUBJECTS_DIR`) should be mounted to `/subjects`
  - The `FS_KEY` environment variable is set to the base64-encoded string of the FreeSurfer license file

#### Example

Suppose:
  - The FreeSurfer install directory lives at `~/fs-xenial/bin`
  - The FreeSurfer subject directory lives at `/tmp/subjects/`
    - The FreeSurfer subject directory contains the subdirectory `bert`, which you would like to recon
  - The `FS_KEY` value is `xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`

Then, the following command will run recon-all on bert:
```
docker run -it --rm \
  -v ${HOME}/fs-xenial/bin:/freesurfer-bin \
  -v /tmp/subjects/:/subjects \
  -e FS_KEY='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx' \
  -u ${UID}:${GID} \
  fs-dev-xenial-recon-all:latest recon-all -all -s bert
```
