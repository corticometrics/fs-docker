# fs-docker

Dockerfiles to support:
- developing FreeSurfer (compiling FreeSurfer from source)
- running development versions of FreeSurfer

Work in Progress

## Compiling FreeSurfer's dev branch

The `freesufer-build` container is used to build the dev branch of FreeSurfer and is based on Ubuntu 16.04.3 LTS (Xenial Xerus).  It is built from the file `build/Dockerfile`

#### Pre-reqs
- Install docker
- Install git
- Install git-annex

#### Setup
Outside the container, we want to make a directory structure that looks like:
```
└── basedir
    ├── bin
    ├── freesurfer
    ├── fs-docker
    └── pkg
```

Where:
  - `basedir` is the base directory (denoted by $FSBASEDIR below)
  - `bin` is where the compiled freesurfer binaries will go
  - `freesurfer` is the FreeSurfer git repo (https://github.com/freesurfer/freesurfer.git)
  - `fs-docker` is this repo (https://github.com:corticometrics/fs-docker.git)
  - `pkg` is where FreeSurfer specific pagakes will go.

The `basedir` directory will get mounted to `/fs` inside the container when it is executed.

Define the base directory; 
```
export FSBASEDIR="/home/paul/cmet/git/fs/"
```

Setup the directory structure; clone repos
```
mkdir $FSBASEDIR
cd $FSBASEDIR
git clone git@github.com:corticometrics/fs-docker.git
git clone https://github.com/freesurfer/freesurfer.git ./freesurfer
mkdir -p ./pkg
mkdir -p ./bin
cd ./freesurfer && git checkout dev
cd $FSBASEDIR
```

Checkout the FreeSurfer git annex (not needed to compile, but to run)
```
cd $FSBASEDIR/freesurfer
git remote add datasrc https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/repo/annex.git
git fetch datasrc
git annex enableremote datasrc
git annex get .
```

Build the `freesurfer-build` docker container
```
cd $FSBASEDIR/fs-docker && make fs-build
```

Jump into the `freesurfer-build` container; mounting `$FSBASEDIR` to `/fs/` inside the container
```
docker run -it --rm \
  -v $FSBASEDIR:/fs \
  corticometrics/freesurfer-build:latest \
  /bin/bash
```

Inside the `freesurfer-build` container; build needed FreeSurfer packages (only itk needed for recon-all); drop them in `/fs/pkg`
```
cd /fs/freesurfer/packages
./build_packages.py --only-itk /fs/pkg
```

Inside the `freesurfer-build` container; build dev branch of FreeSurfer; put binaries in `/fs/bin`
```
cd /fs/freesurfer 
cmake . \
  -DBUILD_GUIS=OFF \
  -DMINIMAL=ON \
  -DMAKE_BUILD_TYPE=Release \
  -DINSTALL_PYTHON_DEPENDENCIES=OFF \
  -DDISTRIBUTE_FSPYTHON=OFF \
  -DCMAKE_INSTALL_PREFIX="/fs/bin" \
  -DFS_PACKAGES_DIR="/fs/pkg" \
  -DGFORTRAN_LIBRARIES="/usr/lib/gcc/x86_64-linux-gnu/5/libgfortran.so" && \
make clean && make -j 8 && make install
```

Now, exit the container
```
exit
```

You should now have compiled FreeSurfer binaries in `$FSBASEDIR/bin`

## Running FreeSurfer

The `freesurfer-run` container is used to run dev branch version of `recon-all` and is based on Ubuntu 16.04.3 LTS (Xenial Xerus).  It is built from the file `run/Dockerfile`

### Pre-reqs
- Install docker
- Obtain FreeSurfer binaries (either by following the steps above to compile or [download](https://surfer.nmr.mgh.harvard.edu/fswiki/DownloadAndInstall))
- Obtain FreeSurfer subject data to recon
- Obtain FreeSurfer license (from [here](https://surfer.nmr.mgh.harvard.edu/registration.html)) 

### Setup

#### Build/Tag Container
```
make fs-run
```

#### Get `FS_KEY` value

The [entrypoint script](run/entrypoint.freesurfer-run.bash) for this container looks for the environment variable `FS_KEY` and, if present, will base64-decode the string and store the contents in the file `$FREESURFER_HOME/license.txt`.  Most of FreeSurfer will not work without this license file.  

Obtaining a license file is free and can be applied for [here](https://surfer.nmr.mgh.harvard.edu/registration.html).  Once you have the license file, run `cat $FREESURFER_HOME/license.txt |base64 -w 0 && echo` to get the string that you should set the `FS_KEY` environment variable to.

#### Recon a subject

The `freesurfer-run` container expects: 
  - 2 volumes to be mounted.
    - The FreeSurfer install directory (`$FREESURFER_HOME`) should be mounted to `/freesurfer-bin` 
    - The FreeSurfer subjects directory (`$SUBJECTS_DIR`) should be mounted to `/subjects`
  - The `FS_KEY` environment variable is set to the base64-encoded string of the FreeSurfer license file

#### Example

Suppose:
  - The FreeSurfer install directory lives at `~/fs-development/bin`
  - The FreeSurfer subject directory lives at `/tmp/subjects/`
    - The FreeSurfer subject directory contains the subdirectory `bert`, which you would like to recon
  - The `FS_KEY` value is `xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`

Then, the following command will run recon-all on bert:
```
docker run -it --rm \
  -v ${HOME}/fs-development/bin:/freesurfer-bin \
  -v /tmp/subjects/:/subjects \
  -e FS_KEY='xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx' \
  -u ${UID}:${GID} \
  corticometrics/freesurfer-run:latest \
  recon-all -all -s bert
```
