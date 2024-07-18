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

# Install the latest release of renv from CRAN
RUN R -e "install.packages('renv', repos = c(CRAN = 'https://cloud.r-project.org'))"

# Copy files (including lockfile!) into the image
# Thanks to .dockerignore, should not copy over renv/ (which is very large)
COPY . /home/rstudio

# Copy renv auto-loader tools
RUN mkdir -p renv
COPY .Rprofile /home/rstudio/.Rprofile
COPY renv/activate.R /home/rstudio/renv/activate.R
COPY renv/settings.json /home/rstudio/renv/settings.json

# Install stringi seperately due to issue with not detecting libicu
RUN R -e "install.packages(\"stringi\")"

# Install openssl seperately due to issue with not detecting libssl
RUN R -e "install.packages(\"openssl\")"

# Restore packages when image is created
# (and hence, new containers created from this image will have R packages
# installed and visible at run time)
RUN R -e "renv::restore(lockfile=\"/home/rstudio/renv.lock\", repos = c(CRAN = \"https://packagemanager.rstudio.com/all/__linux__/focal/latest\"))"
