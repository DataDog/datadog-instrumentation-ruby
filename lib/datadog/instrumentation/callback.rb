module Datadog
  module Instrumentation
    # Code block invoked when hook is triggered
    class Callback
      attr_reader :name

      def initialize(name = nil, opts = {}, &block)
        @name = name
        @block = block
        @disabled = false
      end

      if RUBY_VERSION < '3.0'
        def call(*args, &block)
          return if @disabled

          @block.call(*args, &block)
        end
      else
        def call(*args, **kwargs, &block)
          return if @disabled

          @block.call(*args, **kwargs, &block)
        end
      end

      def disable
        @disabled = true
      end

      def enable
        @disabled = false
      end

      def disabled?
        @disabled
      end
    end
  end
end
