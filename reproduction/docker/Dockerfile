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

# Set project directory
ENV PROJDIRECTORY "/home/rstudio/"
WORKDIR ${PROJDIRECTORY}

# Install remotes, which we can use to install a specific version of renv
RUN R -e "install.packages('remotes', repos = c(CRAN = 'https://cloud.r-project.org'))"
RUN R -e "remotes::install_github('rstudio/renv@${RENV_VERSION}')"

# Copy files (including renv.lock!) into the image
# Thanks to .dockerignore, should not copy over renv/ (which is very large)
#COPY . .
COPY renv.lock renv.lock
COPY reproduction.Rproj reproduction.Rproj
COPY scripts scripts

# Copy renv auto-loader tools
RUN mkdir -p renv/library
COPY .Rprofile .Rprofile
COPY renv/activate.R renv/activate.R

# Install packages
RUN R -e "renv::restore(lockfile='${PROJDIRECTORY}/renv.lock', repos = c(CRAN = 'https://packagemanager.rstudio.com/all/__linux__/focal/latest'))"

# Set user back to root
USER root
