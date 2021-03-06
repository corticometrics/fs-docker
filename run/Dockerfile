# Dockerfile to run recon-all (from the 'dev' branch of FreeSurfer)
# Based on Ubuntu 16.04.3 LTS (Xenial Xerus)
#
# This FreeSurfer environment assumes
#    The freesurfer install ($FREESURFER_HOME) directory is
#      - `/freesurfer-bin`
#    The freesurfer subject directory is
#      - `/subjects`
#
# These must be mounted by the user.

FROM ubuntu:xenial

RUN apt-get update && \
    apt-get install -y \
      bc \
      binutils \
      libgomp1 \
      net-tools \
      perl \
      psmisc \
      sudo \
      tar \
      tcsh \
      unzip \
      uuid-dev \
      vim-common

# Setup the $FREESURFER_HOME dir
# ------------------------------
VOLUME /freesurfer-bin
ENV FREESURFER_HOME=/freesurfer-bin
ENV OS Linux
ENV FS_OVERRIDE 0
ENV FIX_VERTEX_AREA=
ENV FSF_OUTPUT_FORMAT nii.gz
ENV PATH $FREESURFER_HOME/bin:$PATH
## for POSIX compliance-ish https://github.com/freesurfer/freesurfer/pull/83
# ENV FS_POSIX 1
## to supress a `Could not set locale` error when `mri_convert` is run in recon-all
ENV FS_DISABLE_LANG 1

# Setup the $FSUBJECTS_DIR dir
# ------------------------------
VOLUME /subjects
ENV SUBJECTS_DIR /subjects

ADD entrypoint.freesurfer-run.bash /usr/local/bin/entrypoint.bash
RUN chmod +rx /usr/local/bin/entrypoint.bash
ENTRYPOINT ["/usr/local/bin/entrypoint.bash"]
