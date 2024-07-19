# Get base image from rocker
FROM rocker/rstudio:4.4.1

# Set version of packages installed outside the lockfile
ENV RENV_VERSION 'v1.0.7'
ENV STRINGI_VERSION '1.8.4'
ENV OPENSSL_VERSION '2.2.0'

# Install system dependencies
RUN apt-get update && \
	apt-get install -y \
	libcurl4-openssl-dev \
	libssl-dev \
	libxml2-dev \
	libglpk-dev \
	libicu-dev

# Set user to rstudio, so we have access to the renv/ and files
USER rstudio

# Set project directory (otherwise files will copy into an inaccessible location,
# as the rstudio rocker image home is this path)
ENV PROJDIRECTORY "/home/rstudio/"
WORKDIR ${PROJDIRECTORY}

# Copy desired files (inc. renv.lock)
# (run individually rather than with COPY all and .dockerignore, as that was
# inadvertently copying over something that was causing issues)
COPY DESCRIPTION DESCRIPTION
COPY docker docker
COPY outputs outputs
COPY README.md README.md
COPY renv.lock renv.lock
COPY reproduction.Rproj reproduction.Rproj
COPY scripts scripts
COPY tests tests

# Copy renv auto-loader tools
RUN mkdir -p renv/library
COPY .Rprofile .Rprofile
COPY renv/activate.R renv/activate.R

# Install seperately before restore (due to issues with finding system dependencies)
# Running the `renv::` commands will automatically install renv for us
RUN R -e "renv::install('stringi')"
RUN R -e "renv::install('openssl')"

# Install remaining packages
RUN R -e "renv::restore(lockfile='${PROJDIRECTORY}/renv.lock', repos = c(CRAN = 'https://packagemanager.rstudio.com/all/__linux__/focal/latest'))"

# Set user back to root
USER root
