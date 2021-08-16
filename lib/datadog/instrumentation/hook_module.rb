module Datadog
  module Instrumentation
    # Base class for module that inserts hooks
    class HookModule < Module
      def initialize(key)
        super()
        @key = key
      end

      attr_reader :key

      def inspect
        "#<#{self.class.name}: #{@key.inspect}>"
      end
    end
  end
end
