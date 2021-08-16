# Set base image
ARG BASE_IMAGE
FROM ${BASE_IMAGE}

# Setup directory
RUN mkdir /app
WORKDIR /app

# Install dependencies
COPY lib/datadog/instrumentation/version.rb /app/lib/datadog/instrumentation/version.rb
COPY datadog-instrumentation.gemspec /app/datadog-instrumentation.gemspec
COPY Gemfile /app/Gemfile
# This forces gems with native extensions to be compiled, rather than using pre-compiled binaries; it's needed because
# some google-protobuf versions ship with missing binaries for older rubies.
ENV BUNDLE_FORCE_RUBY_PLATFORM true
RUN bundle install

# Set entrypoint
ENTRYPOINT ["/bin/bash", "-c"]
CMD ["rake ci"]
