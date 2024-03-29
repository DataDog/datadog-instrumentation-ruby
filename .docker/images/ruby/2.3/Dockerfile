FROM ruby:2.3

ENV DEBIAN_FRONTEND=noninteractive

# Install prerequisites
RUN set -ex && \
        echo "===> Installing dependencies" && \
        apt-get -y update && \
        apt-get install -y --force-yes --no-install-recommends \
            curl wget tar gzip gnupg apt-transport-https ca-certificates tzdata locales && \
        \
        echo "===> Installing NodeJS" && \
        apt-get install -y --force-yes --no-install-recommends nodejs && \
        \
        echo "===> Installing Yarn" && \
        curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
        echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
        apt-get update && \
        apt-get install -y --force-yes --no-install-recommends yarn && \
        \
        echo "===> Installing database libraries" && \
        apt-get install -y --force-yes --no-install-recommends \
            postgresql-client sqlite3 && \
        \
        echo "===> Installing dev tools" && \
        mkdir -p /usr/share/man/man1 && \
        apt-get install -y --force-yes --no-install-recommends \
            sudo git openssh-client rsync vim \
            net-tools netcat parallel unzip zip bzip2 && \
        \
        echo "===> Cleaning up" && \
        rm -rf /var/lib/apt/lists/*;

# Set timezone to UTC by default
RUN ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime

# Set language
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en

# Install RubyGems
RUN gem update --system
RUN mkdir -p "$GEM_HOME" && chmod -R 777 "$GEM_HOME"

# Install RubyGems
RUN gem update --system
RUN gem install bundler
ENV BUNDLE_SILENCE_ROOT_WARNING 1

# NOTE:
# Ruby 2.3 base image sets BUNDLE_PATH which causes Bundler (>= 2.0) to install to:
#   /usr/local/bundle/ruby/2.3.0/bin
# Instead of the desired:
#   /usr/local/bundle/bin
#
# Because BUNDLE_PATH cannot be removed from ENV (Docker does not permit this),
# we must work around this by adding the bin directory to the PATH.
#
# See:
#  https://github.com/docker-library/ruby/issues/297
#  https://github.com/docker-library/ruby/pull/306
#  https://github.com/rubygems/bundler/issues/7494
ENV GEM_PATH=$GEM_HOME:$GEM_HOME/ruby/$RUBY_MAJOR.0
ENV PATH=$GEM_HOME/bin:$GEM_HOME/ruby/$RUBY_MAJOR.0/bin:$PATH

CMD ["/bin/bash"]
