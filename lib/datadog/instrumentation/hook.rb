require 'datadog/instrumentation/callback'
require 'datadog/instrumentation/hook'
require 'datadog/instrumentation/hook_point'
require 'datadog/instrumentation/stack'

module Datadog
  module Instrumentation
    # Wraps code around a specific class & method
    class Hook
      DEFAULT_STRATEGY = HookPoint::DEFAULT_STRATEGY

      @hooks = {}

      def self.[](hook_point, strategy = DEFAULT_STRATEGY)
        @hooks[hook_point] ||= new(hook_point, nil, strategy)
      end

      def self.add(hook_point, strategy = DEFAULT_STRATEGY, &block)
        self[hook_point, strategy].add(&block)
      end

      def self.ignore
        Thread.current[:hook_entered] = true
        yield
      ensure
        Thread.current[:hook_entered] = false
      end

      attr_reader :point, :stack

      def initialize(hook_point, dependency_test = nil, strategy = DEFAULT_STRATEGY)
        @disabled = false
        @point = hook_point.is_a?(HookPoint) ? hook_point : HookPoint.new(hook_point, strategy)
        @dependency_test = dependency_test || proc { point.exist? }
        @stack = Stack.new
      end

      def dependency?
        @dependency_test.call if @dependency_test
      end

      def add(&block)
        tap { instance_eval(&block) }
      end

      def callback_name(tag = nil)
        point.to_s << (tag ? ":#{tag}" : '')
      end

      def append(tag = nil, opts = {}, &block)
        @stack << Callback.new(callback_name(tag), opts, &block)
      end

      def unshift(tag = nil, opts = {}, &block)
        @stack.unshift Callback.new(callback_name(tag), opts, &block)
      end

      def before(tag = nil, opts = {}, &block)
        # TODO: Implement this.
      end

      def after(tag = nil, opts = {}, &block)
        # TODO: Implement this.
      end

      def depends_on(&block)
        @dependency_test = block
      end

      def enable
        @disabled = false
      end

      def disable
        @disabled = true
      end

      def disabled?
        @disabled
      end

      def install
        return unless point.exist?

        point.install('hook', &Hook.wrapper(self))
      end

      def uninstall
        return unless point.exist?

        point.uninstall('hook', &Hook.wrapper(self))
      end

      class << self
        if RUBY_VERSION < '3.0'
          def wrapper(hook)
            proc do |*args, &_block|
              supa = proc { |*super_args| super(*super_args) }
              mid  = proc { |_, env| { return: supa.call(*env[:args]) } }
              stack = hook.stack.dup
              stack << mid

              stack.call(self: self, args: args)
            end
          end
        else
          def wrapper(hook)
            proc do |*args, **kwargs, &_block|
              supa = proc { |*super_args, **super_kwargs| super(*super_args, **super_kwargs) }
              mid  = proc { |_, env| { return: supa.call(*env[:args], **env[:kwargs]) } }
              stack = hook.stack.dup
              stack << mid

              stack.call(self: self, args: args, kwargs: kwargs)
            end
          end
        end
      end
    end
  end
end
