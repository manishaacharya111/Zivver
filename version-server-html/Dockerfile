# Use the official Tomcat image from the Docker Hub
FROM tomcat:9.0-slim

# Remove the default ROOT webapp
RUN rm -rf /usr/local/tomcat/webapps/ROOT

# Copy our static HTML file to the ROOT webapp directory
COPY index.html /usr/local/tomcat/webapps/ROOT/index.html

# Expose port 8000
EXPOSE 8000

# Tomcat will start by default, no need to specify CMD
