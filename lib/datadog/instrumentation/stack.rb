module Datadog
  module Instrumentation
    # Middleware stack for instrumentation (Rack-style)
    class Stack < Array
      def call(env = {})
        head.call(tail, env)
      end

      def head
        first
      end

      def tail
        Stack.new(self[1..-1])
      end
    end
  end
end
