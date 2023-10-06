# Use rstudio/plumber image as the base image
FROM rstudio/plumber

# Install remotes
RUN R -e "install.packages('remotes', repos = 'http://cran.rstudio.com/')"

# Copy the entire bullseye directory into a directory in the container
COPY . /bullseye

# Navigate to the bullseye directory and install the package
WORKDIR /bullseye
RUN R -e "remotes::install_local('.')"

# Use the plumb_api function to run your API

EXPOSE 8000

ENTRYPOINT ["R", "-e", "plumber::plumb_api('bullseye', 'test_cen_api')$run(port=8000, host='0.0.0.0')"]
