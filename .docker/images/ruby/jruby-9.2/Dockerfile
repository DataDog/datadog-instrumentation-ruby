FROM jruby:9.2

ENV DEBIAN_FRONTEND=noninteractive

# Install prerequisites
RUN set -ex && \
        echo "===> Installing dependencies" && \
        apt-get -y update && \
        apt-get install -y --force-yes --no-install-recommends \
            curl wget tar gzip gnupg apt-transport-https ca-certificates \
            tzdata locales build-essential shared-mime-info && \
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

# Upgrade RubyGems and Bundler
RUN gem uninstall -i /opt/jruby/lib/ruby/gems/shared bundler -v 2.1.4 # Remove when https://github.com/thoughtbot/appraisal/issues/162 is fixed
RUN gem install bundler -v 2.1.2 # Remove when https://github.com/thoughtbot/appraisal/issues/162 is fixed
ENV BUNDLE_SILENCE_ROOT_WARNING 1

# Ensure JRuby is available when running "bash --login"
RUN echo "export PATH=/opt/jruby/bin:$BUNDLE_BIN:\$PATH" >> ~/.profile

CMD ["bin", "bash", "--login"]
