# Datadog Instrumentation API

``datadog-instrumentation`` is Datadog's instrumentation API for Ruby. It can be used to install hooks into Ruby application code, and expose or alter operations for monitoring purposes. This gem is intended as a base for other APM packages, and does not provide any instrumentation out-of-the-box.

For out-of-the-box instrumentation, see these other repositories:
 - [``ddtrace``: Datadog tracing & profiling](https://github.com/DataDog/dd-trace-rb)

## Quickstart

(Work in progress.)

## Development

Docker & docker-compose are required to develop this package locally.

To start a development environment:

1. `bundle install`
2. `rake docker:run`
    - (Optional) Set `RUBY_VER=<RUBY_VERSION>` for a specific version of Ruby.

Then within the development environment...

 - Run tests with `rake spec`
 - Lint with `rake rubocop`
 - Generate docs with `rake docs`
