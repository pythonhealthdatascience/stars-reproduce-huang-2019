# Get base image from rocker
FROM rocker/rstudio:4.1.1

# Install the latest release of renv from CRAN
RUN R -e "install.packages('renv', repos = c(CRAN = 'https://cloud.r-project.org'))"

# Create and set working directory for container
RUN mkdir /home/code
WORKDIR /home/code

# Copy files (including lockfile!) into the image
# Thanks to .dockerignore, should not copy over renv/ (which is very large)
COPY ./reproduction /home/code

# Copy renv auto-loader tools
RUN mkdir -p renv
COPY .Rprofile .Rprofile
COPY renv/activate.R renv/activate.R
COPY renv/settings.json renv/settings.json

# Restore packages when image is created
# (and hence, new containers created from this image will have R packages
# installed and visible at run time)
RUN R -e "renv::restore()"
