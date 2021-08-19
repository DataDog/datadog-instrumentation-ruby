require 'datadog/instrumentation/version'
require 'datadog/instrumentation/hook'

module Datadog
  # Namespace for Datadog instrumentation
  module Instrumentation
  end
end

# Sample class
# TODO: This is testing code... remove this later.
class B
  def hello(*args, **kwargs)
    puts "B args:#{args.inspect}, kwargs:#{kwargs.inspect}"

    ['B', args, kwargs]
  end
end

Datadog::Instrumentation::Hook['B#hello'].add do
  append do |stack, env|
    puts 'X+'
    r = stack.call(env)
    puts 'X-'
    r.merge(foo: 'bar')
  end

  append do |stack, env|
    begin
      p env
      env[:args][0] = 43
      r = stack.call(env)
    ensure
      p env
      p r
    end
  end
end.install

B.new.hello(42, foo: :bar)
