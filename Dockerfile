FROM ubuntu:14.04
FROM ruby:2.1

MAINTAINER tech@execonline.com

RUN apt-get update && apt-get install -y \
  rubygems-integration \
  git-core \
  curl \
  vim

# Set an environment variable to store where the app is installed to inside
# of the Docker image.
ENV INSTALL_PATH /myapp
RUN mkdir -p $INSTALL_PATH

# This sets the context of where commands will be ran in and is documented
# on Docker's website extensively.
WORKDIR $INSTALL_PATH

RUN mkdir ~/.ssh
RUN ssh-keyscan -t rsa github.com > ~/.ssh/known_hosts

COPY . .
ENV BUNDLE_PATH /box
RUN gem install bundler
RUN bundle check || bundle install --jobs 20 --retry 5

# Expose port so we can access it from the outside.
EXPOSE 4567

# The main command to run when the container starts. Also
# tell the Rails dev server to bind to all interfaces by
# default.
CMD ["bundle", "exec", "ruby", "deployer.rb"]
