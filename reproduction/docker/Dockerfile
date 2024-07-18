# Get base image from rocker
FROM rocker/rstudio:4.4.1

# Install system dependencies
RUN apt-get update && apt-get install -y libcairo2-dev libssl-dev make libcurl4-openssl-dev libmysqlclient-dev unixodbc-dev libnode-dev default-jdk libxml2-dev git libfontconfig1-dev libfreetype6-dev libssh2-1-dev zlib1g-dev libglpk-dev libjpeg-dev imagemagick libmagick++-dev gsfonts cmake libpng-dev libtiff-dev python3 libglu1-mesa-dev libgl1-mesa-dev libgdal-dev gdal-bin libgeos-dev libproj-dev libsqlite3-dev libsodium-dev libicu-dev tcl tk tk-dev tk-table libfribidi-dev libharfbuzz-dev libudunits2-dev

# Install the latest release of renv from CRAN
RUN R -e "install.packages('renv', repos = c(CRAN = 'https://cloud.r-project.org'))"

# Create and set working directory for container
RUN mkdir /home/code
WORKDIR /home/code

# Copy files (including lockfile!) into the image
# Thanks to .dockerignore, should not copy over renv/ (which is very large)
COPY . /home/code

# Copy renv auto-loader tools
RUN mkdir -p renv
COPY .Rprofile .Rprofile
COPY renv/activate.R renv/activate.R
COPY renv/settings.json renv/settings.json

# Restore packages when image is created
# (and hence, new containers created from this image will have R packages
# installed and visible at run time)
RUN R -e "renv::restore(repos = c(CRAN = \"https://packagemanager.rstudio.com/all/__linux__/focal/latest\"))"
