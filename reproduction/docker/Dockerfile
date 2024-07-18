# Get base image from rocker
FROM rocker/rstudio:4.4.1

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
ENV PROJDIRECTORY "/home/rstudio/Documents/RStudio/PROJECT"
WORKDIR ${PROJDIRECTORY}

# Set version of packages installed outside the lockfile
ENV RENV_VERSION 'v1.0.7'
ENV STRINGI_VERSION '1.8.4'
ENV OPENSSL_VERSION '2.2.0'

# Install remotes (which we will use to install packages)
RUN Rscript -e "install.packages('remotes', repos = c(CRAN = 'https://cloud.r-project.org'))"

# Install renv from GitHub
RUN Rscript -e "remotes::install_github('rstudio/renv@${RENV_VERSION}')"

# Install stringi seperately due to issue with not detecting libicu
RUN Rscript -e "remotes::install_version('stringi', version='${STRINGI_VERSION}')"

# Install openssl seperately due to issue with not detecting libssl
RUN Rscript -e "remotes::install_version('openssl', version='${OPENSSL_VERSION}')"

# Copy files (including renv.lock!) into the image
# Thanks to .dockerignore, should not copy over renv/ (which is very large)
COPY . .

# Copy renv auto-loader tools
RUN mkdir -p renv/library
COPY .Rprofile .Rprofile
COPY renv/activate.R renv/activate.R

# Restore packages when image is created
# (and hence, new containers created from this image will have R packages
# installed and visible at run time)
RUN R -e "renv::restore(lockfile=\"${PROJDIRECTORY}/renv.lock\", repos = c(CRAN = \"https://packagemanager.rstudio.com/all/__linux__/focal/latest\"))"

# Set user back to root
USER root
