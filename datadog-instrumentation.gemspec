# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'datadog/instrumentation/version'

Gem::Specification.new do |spec|
  spec.name                  = 'datadog-instrumentation'
  spec.version               = Datadog::Instrumentation::VERSION::STRING
  spec.required_ruby_version = [">= #{Datadog::Instrumentation::VERSION::MINIMUM_RUBY_VERSION}", "< #{Datadog::Instrumentation::VERSION::MAXIMUM_RUBY_VERSION}"]
  spec.required_rubygems_version = '>= 2.0.0'
  spec.authors               = ['Datadog, Inc.']
  spec.email                 = ['dev@datadoghq.com']

  spec.summary     = 'Datadog instrumentation hooks Ruby applications'
  spec.description = <<-EOS.gsub(/^[\s]+/, '')
    datadog-instrumentation is Datadog’s instrumentation API for Ruby. It is used
    by other tools to hook into Ruby code to measure or modify code execution.
  EOS

  spec.homepage = 'https://github.com/DataDog/datadog-instrumentation-rb'
  spec.license  = 'BSD-3-Clause'

  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files =
    `git ls-files -z`
    .split("\x0")
    .reject { |f| f.match(%r{^(spec|[.]circleci)/}) }
    .reject do |f|
      ['.dockerignore', '.env', '.rspec', '.rubocop.yml', '.rubocop_todo.yml',
      '.simplecov', 'Gemfile', 'Rakefile', 'docker-compose.yml'].include?(f)
    end
  spec.require_paths = ['lib']
end
