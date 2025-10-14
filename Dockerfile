
# Dockerfile for for R base image with INLA installed
# after installation, can be used interactively with:
# sudo docker run --rm -it docker_r_base bash

# R 4.5 on Ubuntu 22.04 (Jammy)
FROM rstudio/r-base:4.5-noble

RUN echo 'APT::Install-Suggests "0";' > /etc/apt/apt.conf.d/00-docker && \
    echo 'APT::Install-Recommends "0";' >> /etc/apt/apt.conf.d/00-docker

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install -y build-essential gfortran pkg-config git \
    libcurl4-openssl-dev libxml2-dev libssl-dev \
    libudunits2-dev libgdal-dev libgeos-dev libproj-dev libgsl-dev libfontconfig1-dev && \
    rm -rf /var/lib/apt/lists/*

# Install INLA from its tarball (no remotes needed) and other packages.
RUN R -e "install.packages('https://inla.r-inla-download.org/R/testing/src/contrib/INLA_25.06.13.tar.gz', \
          repos = NULL, type = 'source', dependencies = TRUE)"
RUN R -e "install.packages('tidyverse', repos = c(CRAN='https://cloud.r-project.org'), dependencies=TRUE)"
RUN R -e "install.packages(c('tsModel','dlnm','spdep'), repos=c(CRAN='https://cloud.r-project.org'), dependencies=TRUE)"
RUN R -e "install.packages(c('sf'), repos=c(CRAN='https://cloud.r-project.org'), dependencies=TRUE)"

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install -y libabsl-dev
RUN R -e "install.packages(c('pak'), repos=c(CRAN='https://cloud.r-project.org'), dependencies=TRUE)"
# hack: this installs dependencies for fmesher, but fails on fmesher, but then fmesher install works after
#RUN R -e "pak::pkg_install('inlabru-org/fmesher@stable')"
RUN R -e "pak::pak('sf')"
RUN R -e "install.packages(c('fmesher'), repos=c(CRAN='https://cloud.r-project.org'), dependencies=TRUE)"
RUN R -e "install.packages(c('xgboost'), repos=c(CRAN='https://cloud.r-project.org'), dependencies=TRUE)"
RUN R -e "install.packages(c('spdep'), repos=c(CRAN='https://cloud.r-project.org'), dependencies=TRUE)"
RUN R -e "install.packages(c('sn'), repos=c(CRAN='https://cloud.r-project.org'), dependencies=TRUE)"

RUN rm -rf /var/lib/apt/lists/*
RUN useradd -ms /bin/bash apprunner
RUN echo "apprunner:apprunner" | chpasswd
#RUN chmod -R 777  /opt/R/*/lib/R/library/INLA/
RUN chmod -R 777  /opt/R/*

#RUN apt install libc6

# hack because INLA links to another libudev version
#RUN apt-get update && apt-get install -y libudev1
#RUN find /opt/R -path '*/INLA/bin/*/libudev.so.1' -delete
#ENV LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:/lib/x86_64-linux-gnu
#RUN chmod -R 777 /opt/R/*/lib/R/library
#RUN chmod -R 777 /opt/R/*/lib/R/
#USER apprunner

#RUN chmod -R 777 /opt/R/*/lib/R/library
#RUN chmod -R 777 /opt/R/*/lib/R/
#USER apprunner

#docker run --rm -it rstudio/r-base:4.3-jammy

# sudo docker run -ti --rm -v "./:/home/run/" -w /home/run/ docker_r_base Rscript setup.R

# to build:
#  - docker build -t ivargr/r_inla .